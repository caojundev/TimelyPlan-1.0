//
//  CoreDataRemoteChangeManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/18.
//

import Foundation
import CoreData
import Combine

// MARK: - 类型定义
typealias CoreDataRemoteChangeHandler = (CoreDataRemoteChangeManager.ChangeInfo) -> Void

// MARK: - 远程数据变更管理器
class CoreDataRemoteChangeManager {
    
    // MARK: - 单例
    static let shared = CoreDataRemoteChangeManager()
    
    // MARK: - 观察者Token
    struct ObserverToken {
        fileprivate let id: UUID
        fileprivate weak var manager: CoreDataRemoteChangeManager?
        
        func invalidate() {
            manager?.removeObserver(token: self)
        }
    }
    
    // MARK: - 变更信息模型
    struct ChangeInfo {
        let timestamp: Date
        let changesByEntity: [String: EntityChanges]
        
        var entityNames: [EntityName] {
            return changesByEntity.keys.compactMap { EntityName(rawValue: $0) }
        }
        
        var totalChangeCount: Int {
            return changesByEntity.values.reduce(0) { $0 + $1.totalCount }
        }
        
        var debugDescription: String {
            var desc = "📱 远程数据变更 [\(timestamp)]\n"
            for (entityName, changes) in changesByEntity {
                desc += "├─ \(entityName): 新增\(changes.inserted.count) 更新\(changes.updated.count) 删除\(changes.deleted.count)\n"
            }
            return desc
        }
        
        func hasChanges(for entityName: EntityName) -> Bool {
            return changesByEntity[entityName.rawValue] != nil
        }
        
        func changes(for entityName: EntityName) -> EntityChanges? {
            return changesByEntity[entityName.rawValue]
        }
    }
    
    struct EntityChanges {
        let entityName: String
        var inserted: Set<NSManagedObjectID> = []
        var updated: Set<NSManagedObjectID> = []
        var deleted: Set<NSManagedObjectID> = []
        
        var totalCount: Int {
            return inserted.count + updated.count + deleted.count
        }
        
        mutating func merge(with other: EntityChanges) {
            // 删除操作优先级最高
            inserted.subtract(other.deleted)
            updated.subtract(other.deleted)
            
            inserted.formUnion(other.inserted)
            updated.formUnion(other.updated)
            deleted.formUnion(other.deleted)
        }
    }
    
    // MARK: - 配置选项
    struct Configuration {
        /// 防抖等待时间（秒）- 收到最后一条通知后等待这段时间再触发
        var debounceInterval: TimeInterval = 0.8
        /// 最大等待时间（秒）- 防止无限等待的兜底策略
        var maxWaitTime: TimeInterval = 5.0
        /// 变更数量超过此阈值时，防抖时间减半
        var largeBatchThreshold: Int = 50
    }
    
    // MARK: - 私有属性
    private var container: NSPersistentCloudKitContainer?
    private var lastHistoryToken: NSPersistentHistoryToken?
    private var handlerDict: [UUID: (handler: CoreDataRemoteChangeHandler, queue: DispatchQueue)] = [:]
    private let handlerLock = NSLock()
    private let tokenKey = "CoreDataRemoteChangeToken"
    
    // 防抖相关
    private var pendingChanges: [String: EntityChanges] = [:]
    private var pendingChangeCount: Int = 0
    private var debounceTimer: Timer?
    private var maxWaitTimer: Timer?
    private var firstChangeTime: Date?
    private let changeLock = NSLock()
    
    // 标记是否正在防抖等待中
    private var isDebouncing: Bool {
        return debounceTimer != nil
    }
    
    // MARK: - 发布者
    let changePublisher = PassthroughSubject<ChangeInfo, Never>()
    
    // MARK: - 公开配置
    var configuration = Configuration()
    
    private init() {
        setupAppLifecycleObservers()
    }
    
    // MARK: - 配置方法
    
    func configure(with container: NSPersistentCloudKitContainer) {
        container.viewContext.markAsLocal()
        self.container = container
        self.loadToken()
        self.startObserving()
    }
    
    // MARK: - 观察者管理
    
    @discardableResult
    func observe(on queue: DispatchQueue = .main, handler: @escaping CoreDataRemoteChangeHandler) -> ObserverToken {
        let id = UUID()
        handlerLock.lock()
        handlerDict[id] = (handler: handler, queue: queue)
        let count = handlerDict.count
        handlerLock.unlock()
        
        debugPrint("➕ 添加观察者，当前总数: \(count)")
        return ObserverToken(id: id, manager: self)
    }
    
    fileprivate func removeObserver(token: ObserverToken) {
        handlerLock.lock()
        handlerDict.removeValue(forKey: token.id)
        let count = handlerDict.count
        handlerLock.unlock()
        
        debugPrint("➖ 移除观察者，当前总数: \(count)")
    }
    
    func removeAllObservers() {
        handlerLock.lock()
        handlerDict.removeAll()
        handlerLock.unlock()
        debugPrint("🗑 移除所有观察者")
    }
    
    func refreshViewContext() {
        DispatchQueue.main.async { [weak self] in
            self?.container?.viewContext.refreshAllObjects()
        }
    }
    
    // MARK: - App生命周期
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc private func handleAppDidEnterBackground() {
        // 进入后台立即触发
        flushPendingChanges(reason: "进入后台")
    }
    
    // MARK: - 远程变更监听
    
    private func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteChange(_:)),
            name: .NSPersistentStoreRemoteChange,
            object: container?.persistentStoreCoordinator
        )
    }
    
    @objc private func handleRemoteChange(_ notification: Notification) {
        processHistoryChanges()
    }
    
    private func isLocalTransaction(_ transaction: NSPersistentHistoryTransaction) -> Bool {
        let localPrefix = NSManagedObjectContext.localAuthorPrefix
        return transaction.author?.hasPrefix(localPrefix) ?? false
    }
    
    // MARK: - 防抖机制核心
    
    /// 重置防抖计时器（每次收到新变更时调用）
    private func resetDebounceTimer() {
        // 取消现有计时器
        debounceTimer?.invalidate()
        
        // 确定防抖间隔
        var interval = configuration.debounceInterval
        
        // 如果累积变更很多，缩短防抖时间
        if pendingChangeCount >= configuration.largeBatchThreshold {
            interval = configuration.debounceInterval / 2
            debugPrint("⏱ 大量变更(\(pendingChangeCount)条)，防抖时间缩短为: \(String(format: "%.1f", interval))秒")
        }
        
        // 创建新的计时器
        debounceTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.debounceTimerFired()
        }
        
        if let timer = debounceTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
        
        debugPrint("⏱ 重置防抖计时器(\(String(format: "%.1f", interval))秒)，待处理: \(pendingChangeCount)条")
    }
    
    /// 启动最大等待计时器（只在第一次收到变更时启动）
    private func startMaxWaitTimer() {
        guard maxWaitTimer == nil else { return }
        
        maxWaitTimer = Timer.scheduledTimer(withTimeInterval: configuration.maxWaitTime, repeats: false) { [weak self] _ in
            self?.maxWaitTimerFired()
        }
        
        if let timer = maxWaitTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
        
        debugPrint("⏰ 启动最大等待计时器(\(String(format: "%.1f", configuration.maxWaitTime))秒)")
    }
    
    /// 防抖计时器触发：连续没有新变更，可以通知了
    private func debounceTimerFired() {
        changeLock.lock()
        let hasChanges = !pendingChanges.isEmpty
        let count = pendingChangeCount
        changeLock.unlock()
        
        if hasChanges {
            debugPrint("✅ 防抖计时器触发，连续无新变更，发送通知: \(count)条")
            flushPendingChanges(reason: "防抖触发")
        } else {
            debugPrint("⏭ 防抖计时器触发，但无待处理变更")
        }
    }
    
    /// 最大等待计时器触发：兜底策略，防止无限等待
    private func maxWaitTimerFired() {
        changeLock.lock()
        let hasChanges = !pendingChanges.isEmpty
        let count = pendingChangeCount
        changeLock.unlock()
        
        if hasChanges {
            debugPrint("⚠️ 最大等待时间到，强制发送通知: \(count)条")
            flushPendingChanges(reason: "最大等待时间触发")
        }
    }
    
    /// 停止所有计时器
    private func stopAllTimers() {
        debounceTimer?.invalidate()
        debounceTimer = nil
        maxWaitTimer?.invalidate()
        maxWaitTimer = nil
        firstChangeTime = nil
    }
    
    // MARK: - 处理历史变更
    
    private func processHistoryChanges() {
        guard let container = container else { return }
        
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastHistoryToken)
            
            guard let result = try? backgroundContext.execute(fetchRequest) as? NSPersistentHistoryResult,
                  let transactions = result.result as? [NSPersistentHistoryTransaction],
                  !transactions.isEmpty else {
                return
            }
            
            // 过滤本地操作
            let remoteTransactions = transactions.filter { !self.isLocalTransaction($0) }
            
            // 更新Token（无论是否有远程操作都要更新）
            if let lastTransaction = transactions.last {
                self.lastHistoryToken = lastTransaction.token
                self.saveToken()
            }
            
            guard !remoteTransactions.isEmpty else {
                debugPrint("🏠 只有本地操作，不触发通知")
                return
            }
            
            let totalChanges = remoteTransactions.reduce(0) { $0 + ($1.changes?.count ?? 0) }
            debugPrint("🌐 收到 \(remoteTransactions.count) 个远程事务，变更总数: \(totalChanges)")
            
            // 提取并累积变更
            self.accumulateChanges(from: remoteTransactions)
            
            // 在主线程重置防抖计时器
            DispatchQueue.main.async {
                self.handleNewChangesArrived()
            }
        }
    }
    
    /// 累积变更到待处理池
    private func accumulateChanges(from transactions: [NSPersistentHistoryTransaction]) {
        changeLock.lock()
        defer { changeLock.unlock() }
        
        // 记录首次变更时间
        if firstChangeTime == nil {
            firstChangeTime = Date()
        }
        
        for transaction in transactions {
            guard let changes = transaction.changes else { continue }
            
            for change in changes {
                let entityName = change.changedObjectID.entity.name ?? "Unknown"
                var entityChanges = pendingChanges[entityName] ?? EntityChanges(entityName: entityName)
                
                switch change.changeType {
                case .insert:
                    entityChanges.inserted.insert(change.changedObjectID)
                case .update:
                    entityChanges.updated.insert(change.changedObjectID)
                case .delete:
                    entityChanges.deleted.insert(change.changedObjectID)
                @unknown default:
                    break
                }
                
                pendingChanges[entityName] = entityChanges
            }
        }
        
        // 重新计算总数
        pendingChangeCount = pendingChanges.values.reduce(0) { $0 + $1.totalCount }
        
        debugPrint("📦 累积待处理变更: \(pendingChangeCount) 条 (涉及 \(pendingChanges.count) 个实体)")
    }
    
    /// 收到新变更后的处理（在主线程调用）
    private func handleNewChangesArrived() {
        // 启动最大等待计时器（只在第一次时启动）
        startMaxWaitTimer()
        
        // 重置防抖计时器
        resetDebounceTimer()
    }
    
    // MARK: - 刷新变更并通知
    
    private func flushPendingChanges(reason: String) {
        // 停止所有计时器
        stopAllTimers()
        
        changeLock.lock()
        
        guard !pendingChanges.isEmpty else {
            changeLock.unlock()
            debugPrint("⏭ 无待处理变更，跳过通知")
            return
        }
        
        let changes = pendingChanges
        let totalCount = pendingChangeCount
        pendingChanges.removeAll()
        pendingChangeCount = 0
        
        changeLock.unlock()
        
        debugPrint("📢 [\(reason)] 发送通知: \(totalCount)条变更 (涉及\(changes.count)个实体)")
        
        let changeInfo = ChangeInfo(
            timestamp: Date(),
            changesByEntity: changes
        )
        
        // 通知所有观察者
        notifyHandlers(with: changeInfo)
        
        // 发送Combine事件
        DispatchQueue.main.async { [weak self] in
            self?.changePublisher.send(changeInfo)
        }
    }
    
    // MARK: - 通知处理
    
    private func notifyHandlers(with changeInfo: ChangeInfo) {
        handlerLock.lock()
        let currentHandlers = Array(handlerDict.values)
        handlerLock.unlock()
        
        debugPrint("📣 通知 \(currentHandlers.count) 个观察者")
        
        for item in currentHandlers {
            item.queue.async {
                item.handler(changeInfo)
            }
        }
    }
    
    // MARK: - Token持久化
    
    private func saveToken() {
        guard let token = lastHistoryToken,
              let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            return
        }
        UserDefaults.standard.set(data, forKey: tokenKey)
    }
    
    private func loadToken() {
        guard let data = UserDefaults.standard.data(forKey: tokenKey),
              let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: data) else {
            return
        }
        lastHistoryToken = token
    }
    
    deinit {
        stopAllTimers()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - NSManagedObjectContext扩展
extension NSManagedObjectContext {
    
    static let localAuthorPrefix = "LocalDevice"
    
    func markAsLocal() {
        self.transactionAuthor = "\(Self.localAuthorPrefix)_\(UUID().uuidString)"
    }
    
    func setTransactionAuthor(_ author: String) {
        self.transactionAuthor = author
    }
    
    var isLocalContext: Bool {
        return transactionAuthor?.hasPrefix(Self.localAuthorPrefix) ?? false
    }
}

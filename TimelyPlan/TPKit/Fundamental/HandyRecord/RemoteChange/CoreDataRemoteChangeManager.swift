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
    
    // MARK: - 变更信息模型
    struct ChangeInfo {
        let timestamp: Date
        let changesByEntity: [String: EntityChanges]
        let isInitialSync: Bool
        
        var entityNames: [EntityName] {
            var names = [EntityName]()
            for key in changesByEntity.keys {
                if let name = EntityName(rawValue: key) {
                    names.append(name)
                }
            }
            return names
        }
        
        var debugDescription: String {
            var desc = "📱 远程数据变更 [\(timestamp)]\(isInitialSync ? " (初始同步)" : "")\n"
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
        /// 初始同步的触发间隔（秒）
        var initialSyncInterval: TimeInterval = 3.0
        /// 正常运行的触发间隔（秒）
        var normalSyncInterval: TimeInterval = 0.8
        /// 初始同步的最大持续时间（秒）
        var maxInitialSyncDuration: TimeInterval = 10.0
        /// 立即触发的变更阈值
        var immediateFlushThreshold: Int = 50
    }
    
    // MARK: - 私有属性
    private var container: NSPersistentCloudKitContainer?
    private var lastHistoryToken: NSPersistentHistoryToken?
    private var handlers: [(handler: CoreDataRemoteChangeHandler, queue: DispatchQueue)] = []
    private let handlerLock = NSLock()
    private let tokenKey = "CoreDataRemoteChangeToken"
    private let initialSyncKey = "CoreDataInitialSyncCompleted"
    
    // 变更缓存
    private var pendingChanges: [String: EntityChanges] = [:]
    private var pendingChangeCount: Int = 0
    private let changeLock = NSLock()
    
    // 定时器相关
    private var flushTimer: Timer?
    private var initialSyncStartTime: Date?
    private var isInitialSyncCompleted = false
    
    private var isInitialSync: Bool {
        return !UserDefaults.standard.bool(forKey: initialSyncKey) && !isInitialSyncCompleted
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
        
        if isInitialSync {
            debugPrint("🆕 检测到首次启动，将使用初始同步策略")
        }
        
        self.loadToken()
        self.startObserving()
        
        // 在主线程启动定时器
        DispatchQueue.main.async { [weak self] in
            self?.startFlushTimer()
        }
    }
    
    // MARK: - 观察者管理
    
    var count = 0
    func observe(on queue: DispatchQueue = .main, handler: @escaping CoreDataRemoteChangeHandler) {
        count += 1
        print("✅ 添加观察者.....\(count)")
        handlerLock.lock()
        handlers.append((handler: handler, queue: queue))
        handlerLock.unlock()
    }
    
    func removeAllObservers() {
        handlerLock.lock()
        handlers.removeAll()
        handlerLock.unlock()
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func handleAppDidEnterBackground() {
        flushPendingChanges(force: true, reason: "进入后台")
        stopFlushTimer()
    }
    
    @objc private func handleAppWillEnterForeground() {
        DispatchQueue.main.async { [weak self] in
            self?.startFlushTimer()
        }
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
    
    // MARK: - 定时器管理
    
    private func startFlushTimer() {
        stopFlushTimer()
        
        let interval = isInitialSync ? configuration.initialSyncInterval : configuration.normalSyncInterval
        debugPrint("⏰ 启动刷新定时器，间隔: \(interval)秒，模式: \(isInitialSync ? "初始同步" : "正常")")
        
        flushTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            self?.timerFired()
        }
        
        // 确保定时器在滚动等场景下也能触发
        if let timer = flushTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopFlushTimer() {
        flushTimer?.invalidate()
        flushTimer = nil
    }
    
    private func timerFired() {
        changeLock.lock()
        let hasChanges = !pendingChanges.isEmpty
        let count = pendingChangeCount
        let isInitial = isInitialSync
        changeLock.unlock()
        
        if hasChanges {
            debugPrint("⏰ 定时器触发，待处理变更: \(count)条")
            flushPendingChanges(force: false, reason: "定时触发")
        }
        
        // 检查初始同步是否超时
        if isInitial, let startTime = initialSyncStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= configuration.maxInitialSyncDuration {
                debugPrint("⏱ 初始同步超时，强制完成")
                markInitialSyncCompleted()
            }
        }
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
            
            // 过滤掉本地操作
            let remoteTransactions = transactions.filter { !self.isLocalTransaction($0) }
            
            // 更新Token（无论是否有远程操作都要更新）
            if let lastTransaction = transactions.last {
                self.lastHistoryToken = lastTransaction.token
                self.saveToken()
            }
            
            guard !remoteTransactions.isEmpty else {
                return
            }
            
            let totalChanges = remoteTransactions.reduce(0) { $0 + ($1.changes?.count ?? 0) }
            debugPrint("🌐 收到 \(remoteTransactions.count) 个远程事务，变更总数: \(totalChanges)")
            
            // 提取变更信息
            let extractedChanges = self.extractChanges(from: remoteTransactions)
            
            // 累积变更
            let shouldFlushImmediately = self.accumulateChanges(extractedChanges)
            
            // 如果需要立即刷新，在主线程执行
            if shouldFlushImmediately {
                DispatchQueue.main.async {
                    self.flushPendingChanges(force: true, reason: "达到阈值")
                }
            }
        }
    }
    
    private func extractChanges(from transactions: [NSPersistentHistoryTransaction]) -> [String: EntityChanges] {
        var changesByEntity: [String: EntityChanges] = [:]
        
        for transaction in transactions {
            guard let changes = transaction.changes else { continue }
            
            for change in changes {
                let entityName = change.changedObjectID.entity.name ?? "Unknown"
                var entityChanges = changesByEntity[entityName] ?? EntityChanges(entityName: entityName)
                
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
                
                changesByEntity[entityName] = entityChanges
            }
        }
        
        return changesByEntity
    }
    
    // MARK: - 变更累积
    
    /// 累积变更并返回是否需要立即刷新
    private func accumulateChanges(_ newChanges: [String: EntityChanges]) -> Bool {
        changeLock.lock()
        defer { changeLock.unlock() }
        
        // 如果是初始同步，记录开始时间
        if isInitialSync && initialSyncStartTime == nil {
            initialSyncStartTime = Date()
            debugPrint("🔄 开始初始同步")
        }
        
        // 合并变更
        for (entityName, changes) in newChanges {
            if var existing = pendingChanges[entityName] {
                let oldCount = existing.totalCount
                existing.merge(with: changes)
                pendingChanges[entityName] = existing
                pendingChangeCount += (existing.totalCount - oldCount)
            } else {
                pendingChanges[entityName] = changes
                pendingChangeCount += changes.totalCount
            }
        }
        
        debugPrint("📦 累积待处理变更: \(pendingChangeCount) 条 (涉及 \(pendingChanges.count) 个实体)")
        
        // 检查是否需要立即刷新
        let shouldFlushImmediately = pendingChangeCount >= configuration.immediateFlushThreshold
        
        // 检查初始同步是否即将超时
        if !shouldFlushImmediately && isInitialSync, let startTime = initialSyncStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= configuration.maxInitialSyncDuration * 0.8 {
                return true
            }
        }
        
        return shouldFlushImmediately
    }
    
    // MARK: - 刷新变更
    
    private func flushPendingChanges(force: Bool, reason: String) {
        changeLock.lock()
        
        guard !pendingChanges.isEmpty else {
            changeLock.unlock()
            return
        }
        
        let changes = pendingChanges
        let isInitial = isInitialSync
        pendingChanges.removeAll()
        pendingChangeCount = 0
        
        changeLock.unlock()
        
        // 如果是初始同步完成
        if isInitial {
            markInitialSyncCompleted()
        }
        
        let totalChanges = changes.values.reduce(0) { $0 + $1.totalCount }
        debugPrint("📢 [\(reason)] 发送批量通知: \(totalChanges) 条变更 (涉及 \(changes.count) 个实体)")
        
        let changeInfo = ChangeInfo(
            timestamp: Date(),
            changesByEntity: changes,
            isInitialSync: isInitial
        )
        
        // 通知观察者
        notifyHandlers(with: changeInfo)
        
        // 发送 Combine 事件
        DispatchQueue.main.async {
            self.changePublisher.send(changeInfo)
        }
    }
    
    private func markInitialSyncCompleted() {
        guard isInitialSync else { return }
        
        isInitialSyncCompleted = true
        UserDefaults.standard.set(true, forKey: initialSyncKey)
        initialSyncStartTime = nil
        debugPrint("✅ 初始同步完成，切换到正常模式")
        
        // 重新启动定时器（使用正常间隔）
        DispatchQueue.main.async { [weak self] in
            self?.startFlushTimer()
        }
    }
    
    // MARK: - 通知处理
    
    private func notifyHandlers(with changeInfo: ChangeInfo) {
        handlerLock.lock()
        let currentHandlers = handlers
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
        stopFlushTimer()
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

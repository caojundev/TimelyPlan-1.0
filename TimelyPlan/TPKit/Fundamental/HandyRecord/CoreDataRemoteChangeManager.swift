//
//  CoreDataRemoteChangeManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/18.
//

import Foundation
import CoreData
import Combine

// MARK: - 远程数据变更管理器
class CoreDataRemoteChangeManager {
    
    // MARK: - 单例
    static let shared = CoreDataRemoteChangeManager()
    
    // MARK: - 类型定义
    typealias RemoteChangeHandler = (ChangeInfo) -> Void
    
    // MARK: - 变更信息模型
    struct ChangeInfo {
        let timestamp: Date
        let changesByEntity: [String: EntityChanges]
        
        var debugDescription: String {
            var desc = "📱 远程数据变更 [\(timestamp)]\n"
            for (entityName, changes) in changesByEntity {
                desc += "├─ \(entityName): 新增\(changes.inserted.count) 更新\(changes.updated.count) 删除\(changes.deleted.count)\n"
            }
            return desc
        }
        
        func hasChanges(for entityName: String) -> Bool {
            return changesByEntity[entityName] != nil
        }
        
        func changes(for entityName: String) -> EntityChanges? {
            return changesByEntity[entityName]
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
    }
    
    
    // MARK: - 私有属性
    private var container: NSPersistentCloudKitContainer?
    private var lastHistoryToken: NSPersistentHistoryToken?
    private var handlers: [(handler: RemoteChangeHandler, queue: DispatchQueue)] = []
    private let handlerLock = NSLock()
    private let tokenKey = "CoreDataRemoteChangeToken"
    
    // MARK: - Combine 发布者
    let changePublisher = PassthroughSubject<ChangeInfo, Never>()
    
    private init() {}
    
    // MARK: - 配置方法
    
    /// 配置管理器并启动监听
    /// - Parameter container: NSPersistentCloudKitContainer 实例
    func configure(with container: NSPersistentCloudKitContainer) {
        // 给 viewContext 打上本地标记
        container.viewContext.markAsLocal()
        self.container = container
        self.loadToken()
        self.startObserving()
    }
    
    // MARK: - 观察者管理
    
    /// 注册远程变更回调
    /// - Parameters:
    ///   - queue: 回调执行的队列，默认为主队列
    ///   - handler: 变更处理闭包
    func observe(on queue: DispatchQueue = .main, handler: @escaping RemoteChangeHandler) {
        handlerLock.lock()
        handlers.append((handler: handler, queue: queue))
        handlerLock.unlock()
    }
    
    /// 移除所有观察者
    func removeAllObservers() {
        handlerLock.lock()
        handlers.removeAll()
        handlerLock.unlock()
    }
    
    /// 手动刷新 viewContext
    func refreshViewContext() {
        DispatchQueue.main.async { [weak self] in
            self?.container?.viewContext.refreshAllObjects()
        }
    }
    
    // MARK: - 私有方法
    
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
            
            // 过滤掉本地操作，只保留远程操作
            let remoteTransactions = transactions.filter { !self.isLocalTransaction($0) }
            
            // 更新 Token（不论是否有远程操作）
            if let lastTransaction = transactions.last {
                self.lastHistoryToken = lastTransaction.token
                self.saveToken()
            }
            
            // 没有远程操作就不通知
            guard !remoteTransactions.isEmpty else {
                debugPrint("🏠 只有本地操作，不通知 UI")
                return
            }
            
            debugPrint("🌐 有 \(remoteTransactions.count) 个远程操作")
            
            // 处理远程变更并通知 UI
            var changesByEntity: [String: EntityChanges] = [:]
            for transaction in remoteTransactions {
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
            
            let changeInfo = ChangeInfo(timestamp: Date(), changesByEntity: changesByEntity)
            
            // 通知观察者
            self.notifyHandlers(with: changeInfo)
            
            DispatchQueue.main.async {
                self.changePublisher.send(changeInfo)
            }
        }
    }
    
    private func notifyHandlers(with changeInfo: ChangeInfo) {
        handlerLock.lock()
        let currentHandlers = handlers
        handlerLock.unlock()
        
        for item in currentHandlers {
            item.queue.async {
                item.handler(changeInfo)
            }
        }
    }
    
    // MARK: - Token 持久化
    
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
}

extension NSManagedObjectContext {
    
    static let localAuthorPrefix = "LocalDevice"
    
    /// 设置上下文为本地操作上下文
    func markAsLocal() {
        self.transactionAuthor = "\(Self.localAuthorPrefix)_\(UUID().uuidString)"
    }
    
    /// 设置上下文为特定来源
    func setTransactionAuthor(_ author: String) {
        self.transactionAuthor = author
    }
    
    /// 检查是否为本地上下文
    var isLocalContext: Bool {
        return transactionAuthor?.hasPrefix(Self.localAuthorPrefix) ?? false
    }
}

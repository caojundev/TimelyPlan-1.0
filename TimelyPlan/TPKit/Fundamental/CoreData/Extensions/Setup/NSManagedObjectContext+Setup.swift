//
//  NSManagedObjectContext+Setup.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

// MARK: - 全局上下文引用

/// iCloud 设置通知观察者
/// 用于监听 iCloud 可用性变化
var HandyRecordUbiquitySetupNotificationObserver: Any?

/// 根保存上下文（Root Saving Context）
/// 直接与持久化存储协调器关联，负责将数据写入磁盘
var HandyRecordRootSavingContext: NSManagedObjectContext!

/// 默认主队列上下文（Default Main Queue Context）
/// 用于 UI 绑定的主线程上下文，通常与 NSFetchedResultsController 配合使用
var HandyRecordDefaultContext: NSManagedObjectContext!

// MARK: - NSManagedObjectContext 扩展：上下文管理

extension NSManagedObjectContext {
    
    // MARK: 上下文堆栈初始化
    
    /// 初始化 CoreData 上下文堆栈
    /// 创建三层上下文结构：根保存上下文 → 默认主队列上下文
    /// - Parameter container: CoreData 持久化容器
    /// - Note: 仅在首次调用时初始化，避免重复创建
    static func initialize(withContainer container: NSPersistentContainer) {
        // 防止重复初始化
        guard HandyRecordDefaultContext == nil else {
            return
        }
        
        // 创建根保存上下文（私有队列，直接关联持久化存储协调器）
        let rootContext = context(withStoreCoordinator: container.persistentStoreCoordinator)
        rootContext.markAsLocal()
        setRootSavingContext(rootContext)
        
        // 创建默认主队列上下文（主线程，作为根上下文的子上下文）
        let defaultContext = newMainQueueContext()
        defaultContext.markAsLocal()
        setDefaultContext(defaultContext)
        defaultContext.parent = rootContext
    }
 
    // MARK: 根保存上下文配置
    
    /// 设置根保存上下文
    /// 配置合并策略、自动获取永久 ID，并注册保存通知
    /// - Parameter context: 新的根保存上下文
    static func setRootSavingContext(_ context: NSManagedObjectContext) {
        // 移除旧上下文的通知观察者
        if HandyRecordRootSavingContext != nil {
            NotificationCenter.default.removeObserver(rootSavingContext)
        }
        
        // 更新全局引用
        HandyRecordRootSavingContext = context
        
        // 在上下文队列中配置属性
        HandyRecordRootSavingContext.perform {
            // 自动为插入的对象获取永久 ID
            HandyRecordRootSavingContext.obtainPermanentIDsBeforeSaving()
            
            // 设置合并策略：属性级别的合并，新值覆盖旧值
            HandyRecordRootSavingContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }
    
    // MARK: 默认上下文配置
    
    /// 设置默认主队列上下文
    /// 配置 iCloud 监听、根上下文保存通知等
    /// - Parameter context: 新的默认主队列上下文
    static func setDefaultContext(_ context: NSManagedObjectContext) {
        // 清理旧的默认上下文相关资源
        cleanupOldDefaultContext()
        
        // 更新全局引用
        HandyRecordDefaultContext = context
        
        // 注册根上下文保存通知监听
        registerRootContextSaveNotification()
        
        // 配置新上下文的属性
        context.obtainPermanentIDsBeforeSaving()
        
        // 如果启用 iCloud，则监听远程变更
        if HandyRecord.isICloudEnabled {
            let coordinator = NSPersistentStoreCoordinator.defaultStoreCoordinator
            defaultContext.observeICloudChanges(inCoordinator: coordinator)
        }
    }
    
    /// 清理旧默认上下文的资源和观察者
    private static func cleanupOldDefaultContext() {
        // 移除旧默认上下文的通知观察者
        if HandyRecordDefaultContext != nil {
            NotificationCenter.default.removeObserver(HandyRecordDefaultContext!)
        }
        
        // 移除 iCloud 设置通知观察者
        if let observer = HandyRecordUbiquitySetupNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
            HandyRecordUbiquitySetupNotificationObserver = nil
        }
        
        // 停止旧上下文的 iCloud 监听
        if let defaultContext = HandyRecordDefaultContext,
           HandyRecord.isICloudEnabled {
            let coordinator = NSPersistentStoreCoordinator.defaultStoreCoordinator
            defaultContext.stopObservingICloudChanges(inCoordinator: coordinator)
        }
    }
    
    /// 注册根上下文保存通知
    /// 当根上下文保存时，默认上下文需要合并变更
    private static func registerRootContextSaveNotification() {
        guard HandyRecordRootSavingContext != nil else {
            return
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rootContextDidSave(_:)),
            name: Self.didSaveObjectsNotification,
            object: HandyRecordRootSavingContext
        )
    }
    
    // MARK: 上下文访问器
    
    /// 默认主队列上下文
    /// 线程安全的主线程上下文访问器
    /// - Note: 使用 NSLock 确保多线程环境下的安全访问
    public class var defaultContext: NSManagedObjectContext {
        let lock = NSLock()
        lock.lock()
        defer { lock.unlock() }
        
        assert(HandyRecordDefaultContext != nil,
               "默认上下文未初始化！请先调用 initialize(withContainer:) 方法。")
        return HandyRecordDefaultContext
    }
    
    /// 根保存上下文
    /// 直接与持久化存储协调器关联的私有队列上下文
    /// - Note: 所有数据的最终保存都通过此上下文进行
    public class var rootSavingContext: NSManagedObjectContext {
        assert(HandyRecordRootSavingContext != nil,
               "根保存上下文未初始化！请先调用 initialize(withContainer:) 方法。")
        return HandyRecordRootSavingContext
    }
    
    // MARK: 上下文工厂方法
    
    /// 创建子上下文（私有队列）
    /// - Parameter parentContext: 父上下文
    /// - Returns: 配置好的子上下文，自动获取永久 ID
    /// - Note: 适用于后台数据操作，保存时会自动推送到父上下文
    static func context(withParent parentContext: NSManagedObjectContext) -> NSManagedObjectContext {
        let context = newPrivateQueueContext()
        context.parent = parentContext
        context.obtainPermanentIDsBeforeSaving()
        return context
    }

    /// 创建根上下文（直接关联持久化存储协调器）
    /// - Parameter coordinator: 持久化存储协调器
    /// - Returns: 配置好的私有队列根上下文
    static func context(withStoreCoordinator coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        let context = newPrivateQueueContext()
        context.performAndWait {
            context.persistentStoreCoordinator = coordinator
        }
        return context
    }

    /// 创建主队列上下文
    /// - Returns: 主线程并发类型的上下文
    /// - Note: 用于 UI 相关的数据操作，避免阻塞主线程
    static func newMainQueueContext() -> NSManagedObjectContext {
        return Self.init(concurrencyType: .mainQueueConcurrencyType)
    }
    
    /// 创建私有队列上下文
    /// - Returns: 私有队列并发类型的上下文
    /// - Note: 用于后台数据操作，避免阻塞主线程
    static func newPrivateQueueContext() -> NSManagedObjectContext {
        return Self.init(concurrencyType: .privateQueueConcurrencyType)
    }
    
    // MARK: 通知处理
    
    /// 注册保存前自动获取永久 ID 的通知
    /// - Note: 确保插入的对象在保存前获得永久 ID，便于跨上下文传递
    private func obtainPermanentIDsBeforeSaving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextWillSave(_:)),
            name: Self.willSaveObjectsNotification,
            object: self
        )
    }

    /// 处理上下文即将保存通知
    /// 为所有新插入的对象获取永久 ID
    /// - Parameter notification: 保存通知对象
    @objc private func contextWillSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            return
        }
        
        let insertedObjects = context.insertedObjects
        guard !insertedObjects.isEmpty else {
            return
        }
        
        do {
            // 批量获取永久 ID，提高效率
            try context.obtainPermanentIDs(for: Array(insertedObjects))
        } catch {
            let nsError = error as NSError
            debugPrint("获取永久 ID 失败: \(nsError), \(nsError.userInfo)")
        }
    }

    /// 处理根上下文保存完成通知
    /// 将根上下文的变更合并到默认主队列上下文中
    /// - Parameter notification: 保存完成通知
    @objc private class func rootContextDidSave(_ notification: Notification) {
        // 验证通知来源是否正确
        guard let savingContext = notification.object as? NSManagedObjectContext,
              savingContext == rootSavingContext else {
            return
        }
        
        // 确保在主线程执行合并操作（主队列上下文必须在主线程操作）
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.rootContextDidSave(notification)
            }
            return
        }
        
        // 触发已更新对象的懒加载刷新
        refreshUpdatedObjects(from: notification)
        
        // 将根上下文的变更合并到默认上下文
        defaultContext.mergeChanges(fromContextDidSave: notification)
    }
    
    /// 刷新通知中已更新的对象
    /// 通过触发懒加载确保对象属性是最新的
    /// - Parameter notification: 保存完成通知
    private class func refreshUpdatedObjects(from notification: Notification) {
        guard let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? [NSManagedObject] else {
            return
        }
        
        for object in updatedObjects {
            // willAccessValue 触发懒加载，确保对象数据为最新
            defaultContext.object(with: object.objectID).willAccessValue(forKey: nil)
        }
    }
}

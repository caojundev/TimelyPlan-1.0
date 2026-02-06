//
//  NSManagedObjectContext+Setup.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

var HandyRecordUbiquitySetupNotificationObserver: Any?
var HandyRecordRootSavingContext: NSManagedObjectContext!
var HandyRecordDefaultContext: NSManagedObjectContext!

extension NSManagedObjectContext {
   
    /// 删除集合中所有对象
    func deleteObjects(_ objects: [NSManagedObject]) {
        for object in objects {
            delete(object)
        }
    }
    
}

extension NSManagedObjectContext {
    
    // MARK: - setup
    /// 初始化默认上下文
    static func initialize(withContainer container: NSPersistentContainer) {
        if HandyRecordDefaultContext == nil {
            let rootContext = context(withStoreCoordinator: container.persistentStoreCoordinator)
            setRootSavingContext(rootContext)

            let defaultContext = newMainQueueContext()
            setDefaultContext(defaultContext)
            defaultContext.parent = rootContext
        }
    }
 
    static func setRootSavingContext(_ context: NSManagedObjectContext) {
        if HandyRecordRootSavingContext != nil {
            NotificationCenter.default.removeObserver(rootSavingContext)
        }
        
        HandyRecordRootSavingContext = context
        HandyRecordRootSavingContext.perform {
            HandyRecordRootSavingContext.obtainPermanentIDsBeforeSaving()
            HandyRecordRootSavingContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }
    
    static func setDefaultContext(_ context: NSManagedObjectContext) {
        if HandyRecordDefaultContext != nil {
            NotificationCenter.default.removeObserver(HandyRecordDefaultContext!)
        }

        if let observer = HandyRecordUbiquitySetupNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
            HandyRecordUbiquitySetupNotificationObserver = nil;
        }

        let coordinator = NSPersistentStoreCoordinator.defaultStoreCoordinator  
        if let defaultContext = HandyRecordDefaultContext, HandyRecord.isICloudEnabled {
            defaultContext.stopObservingICloudChanges(inCoordinator: coordinator)
        }

        HandyRecordDefaultContext = context
        if HandyRecordRootSavingContext != nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(rootContextDidSave(_:)),
                                                   name: Self.didSaveObjectsNotification,
                                                   object: HandyRecordRootSavingContext)
        }

        context.obtainPermanentIDsBeforeSaving()
        if HandyRecord.isICloudEnabled {
            defaultContext.observeICloudChanges(inCoordinator: coordinator)
        }
    }
    
    // MARK: - Default Contexts
    // Default Context
    private static let lock = NSLock()
    public class var defaultContext: NSManagedObjectContext {
        lock.lock()
        defer { lock.unlock() }
        assert(HandyRecordDefaultContext != nil, "Default context is nil!")
        return HandyRecordDefaultContext
    }
    
    // Root Saving Context
    public class var rootSavingContext: NSManagedObjectContext {
        assert(HandyRecordRootSavingContext != nil, "Root saving context is nil!")
        return HandyRecordRootSavingContext
    }
    
    // MARK: - 创建上下文
    static func context(withParent parentContext: NSManagedObjectContext) -> NSManagedObjectContext {
        let context = newPrivateQueueContext()
        context.parent = parentContext
        context.obtainPermanentIDsBeforeSaving()
        return context
    }

    static func context(withStoreCoordinator coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        let context = newPrivateQueueContext()
        context.performAndWait {
            context.persistentStoreCoordinator = coordinator
        }
        
        return context
    }

    /// 创建新的主队列上下文
    static func newMainQueueContext() -> NSManagedObjectContext {
        let context = Self.init(concurrencyType: .mainQueueConcurrencyType)
        return context
    }
    
    /// 创建新的子队列上下文
    static func newPrivateQueueContext() -> NSManagedObjectContext {
        let context = Self.init(concurrencyType: .privateQueueConcurrencyType)
        return context
    }
    
    // MARK: - Notification
    private func obtainPermanentIDsBeforeSaving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextWillSave(_:)),
                                               name: Self.willSaveObjectsNotification,
                                               object: self)
    }

    /// 处理上下文保存前
    @objc func contextWillSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            return
        }
        
        let insertObjects = context.insertedObjects
        if insertObjects.count > 0 {
            do {
                /// 为插入的对象获取永久ID
                try context.obtainPermanentIDs(for: Array(insertObjects))
            } catch {
                let nserror = error as NSError
                debugPrint("context obtainPermanentIDs error: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    /// 根保存上下文保存后类方法
    @objc class func rootContextDidSave(_ notification: Notification) {
        guard let contenxt = notification.object as? NSManagedObjectContext, contenxt == rootSavingContext else {
            return
        }
        
        if !Thread.isMainThread {
            /// 保证在主线程执行
            DispatchQueue.main.async {
                self.rootContextDidSave(notification)
            }
            
            return
        }
        
        if let objects = notification.userInfo?[NSUpdatedObjectsKey] as? [NSManagedObject] {
            for object in objects {
                /// 获取给定ID的对象，将其标记为即将访问的键值
                defaultContext.object(with: object.objectID).willAccessValue(forKey: nil)
            }
        }
        
        /// 将保存通知所带来的变化合并到默认上下文中
        defaultContext.mergeChanges(fromContextDidSave: notification)
    }
}

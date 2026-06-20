//
//  HandyRecord.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

// MARK: - CoreData 管理器

/// HandyRecord 负责 CoreData 堆栈的初始化、配置和管理
/// 提供同步/异步保存操作，支持 iCloud 同步
class HandyRecord {

    /// CoreData 数据模型文件名称
    static let kContainerName = "TimelyPlan"

    /// iCloud 容器标识符
    /// 格式：iCloud.{teamID}.{bundleID}
    static let kUbiquityContainerIdentifier = "iCloud.com.caojun.TimelyPlan"


    // MARK: 保存选项
    
    /// 保存操作的配置选项
    /// 使用 OptionSet 支持多种选项的组合
    struct SaveOptions: OptionSet {
        
        let rawValue: UInt
        
        /// 空选项，仅保存当前上下文
        static let none = SaveOptions([])
        
        /// 级联保存父级上下文，直到更改持久化到存储层
        static let parentContexts = SaveOptions(rawValue: 1 << 0)
        
        /// 同步保存，阻塞当前线程直到保存完成
        static let synchronously = SaveOptions(rawValue: 1 << 1)
        
        /// 同步保存当前上下文，但异步保存根上下文
        /// 适用于需要在当前线程确认保存完成，但不需要等待持久化存储写入的场景
        static let synchronouslyExceptRootContext = SaveOptions(rawValue: 1 << 2)
    }
    
    // MARK: iCloud 配置
    
    /// 是否启用 iCloud 同步
    /// 默认开启，可根据应用配置动态调整
    static var isICloudEnabled: Bool = true
    
    // MARK: 异步保存操作
    
    /// 使用默认上下文进行异步保存
    /// - Parameter completion: 保存完成后的回调，在主线程执行
    class func save(completion: HandyRecordSaveCompletionHandler? = nil) {
        let defaultContext = NSManagedObjectContext.defaultContext
        defaultContext.saveWithOptions([.parentContexts], completion: completion)
    }
    
    /// 在临时上下文中执行操作并异步保存
    /// - Parameter block: 在临时上下文中执行的操作闭包
    class func save(block: HandyRecordSaveBlock?) {
        save(block: block, completion: nil)
    }
    
    /// 在临时上下文中执行操作并异步保存，支持完成回调
    /// - Parameters:
    ///   - block: 在临时上下文中执行的操作闭包，通常用于创建或修改数据
    ///   - completion: 保存完成后的回调，在主线程执行
    /// - Note: 使用独立的临时上下文，避免阻塞主线程
    class func save(block: HandyRecordSaveBlock? = nil,
                    completion: HandyRecordSaveCompletionHandler?) {
        let savingContext = NSManagedObjectContext.rootSavingContext
        let localContext = NSManagedObjectContext.context(withParent: savingContext)
        
        localContext.perform {
            // 在临时上下文中执行用户操作
            block?(localContext)
            
            // 保存临时上下文并级联到父上下文
            localContext.saveWithOptions([.parentContexts], completion: completion)
        }
    }

    // MARK: 同步保存操作
    
    /// 在临时上下文中执行操作并同步保存
    /// - Parameters:
    ///   - block: 在临时上下文中执行的操作闭包
    ///   - completion: 保存完成后的回调，在主线程执行
    /// - Note: 使用 performAndWait 阻塞当前线程，确保操作完成后再继续执行
    /// - Warning: 避免在主线程调用此方法，可能造成 UI 卡顿
    class func save(blockAndWait block: HandyRecordSaveBlock?,
                    completion: HandyRecordSaveCompletionHandler?) {
        let savingContext = NSManagedObjectContext.rootSavingContext
        let localContext = NSManagedObjectContext.context(withParent: savingContext)
        
        localContext.performAndWait {
            // 在临时上下文中同步执行用户操作
            block?(localContext)
            
            // 同步保存临时上下文并级联到父上下文
            localContext.saveWithOptions([.parentContexts, .synchronously], completion: completion)
        }
    }
    
    // MARK: - CoreData 堆栈初始化
    
    /// 初始化 CoreData 持久化容器和上下文堆栈
    /// - Parameter completion: 初始化完成回调，参数为是否成功
    /// - Note: 该方法会配置 iCloud 同步、远程变更监听和默认上下文
    static func setup(completion: @escaping (Bool) -> Void) {
        setupContainer(name: kContainerName) { container in
            guard let container = container else {
                completion(false)
                return
            }
            
            // 配置持久化存储协调器
            let coordinator = container.persistentStoreCoordinator
            NSPersistentStoreCoordinator.defaultStoreCoordinator = coordinator
            
            // 初始化托管对象上下文堆栈
            NSManagedObjectContext.initialize(withContainer: container)
            
            // 配置远程变更管理器，用于监听 iCloud 或其他上下文的变更
            configureRemoteChangeManager(with: container)
            
            completion(true)
        }
    }
    

    // MARK: 私有方法 - 容器配置
    
    /// 配置远程变更管理器
    /// - Parameter container: 持久化容器
    private static func configureRemoteChangeManager(with container: NSPersistentCloudKitContainer) {
        let changeManager = CoreDataRemoteChangeManager.shared
        changeManager.configure(with: container)
#if DEBUG
        // 监听远程变更并在主线程打印调试信息
        changeManager.observe(on: .main) { changeInfo in
            print("========== 远程数据变更 ==========")
            print(changeInfo.debugDescription)
            print("==================================\n")
        }
#endif
    }
    
    // 监听远程变更
    static func observeRemoteChange(handler: @escaping CoreDataRemoteChangeHandler) {
        CoreDataRemoteChangeManager.shared.observe(on: .main, handler: handler)
    }
    
    /// 根据名称初始化持久化容器
    /// - Parameters:
    ///   - name: 数据模型文件名称（.xcdatamodeld 文件名）
    ///   - completion: 容器加载完成回调，在主线程执行
    private static func setupContainer(
        name: String,
        completion: @escaping (NSPersistentCloudKitContainer?) -> Void
    ) {
        let container = NSPersistentCloudKitContainer(name: name)
        
        // 获取并验证持久化存储描述
        guard let description = container.persistentStoreDescriptions.first else {
            debugPrint("无法获取持久化存储描述")
            completion(nil)
            return
        }
        
        // 配置持久化存储选项
        configureStoreDescription(
            description,
            storeName: name,
            containerID: kUbiquityContainerIdentifier
        )
        
        // 配置视图上下文自动合并变更
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // 加载持久化存储
        container.loadPersistentStores { [container] _, error in
            if let error = error {
                debugPrint("加载持久化存储失败: \(error.localizedDescription)")
                fatalError("无法加载持久化存储: \(error.localizedDescription)")
            }
            
            // 在主线程回调，确保 UI 更新安全
            DispatchQueue.main.async {
                completion(container)
            }
        }
    }
    
    /// 配置持久化存储描述
    /// - Parameters:
    ///   - description: 持久化存储描述对象
    ///   - storeName: 存储文件名称（不含扩展名）
    ///   - containerID: iCloud 容器标识符
    private static func configureStoreDescription(
        _ description: NSPersistentStoreDescription,
        storeName: String,
        containerID: String
    ) {
        // 配置存储文件 URL（支持 iCloud 和本地存储）
        let storeURL = getStoreURL(
            storeName,
            containerID: containerID,
            cloudStorePathComponent: nil
        )
        description.setOption(storeURL as NSURL, forKey: NSPersistentStoreURLKey)
        
        // 启用远程变更通知（用于 iCloud 同步）
        description.setOption(
            NSNumber(value: true),
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        
        // 启用持久化历史追踪（用于增量同步和冲突解决）
        description.setOption(
            NSNumber(value: true),
            forKey: NSPersistentHistoryTrackingKey
        )
    }
    
    // MARK: 存储 URL 生成
    
    /// 获取持久化存储文件的 URL
    /// - Parameters:
    ///   - storeIdentifier: 存储文件标识符（用作文件名）
    ///   - containerID: iCloud 容器标识符
    ///   - cloudStorePathComponent: iCloud 容器内的子路径，nil 则存储在根目录
    /// - Returns: 存储文件的完整 URL
    /// - Note: 优先使用 iCloud 容器 URL，如果不可用则回退到本地文档目录
    static func getStoreURL(
        _ storeIdentifier: String,
        containerID: String,
        cloudStorePathComponent: String?
    ) -> URL {
        let storeName = "\(storeIdentifier).sqlite"
        let fileManager = FileManager.default
        
        // 尝试获取 iCloud 容器 URL
        if let iCloudBaseURL = fileManager.url(forUbiquityContainerIdentifier: containerID) {
            var storeURL = iCloudBaseURL
            
            // 如果有子路径，追加到 URL
            if let subPathComponent = cloudStorePathComponent {
                storeURL.appendPathComponent(subPathComponent)
            }
            
            return storeURL.appendingPathComponent(storeName)
        } else {
            // iCloud 不可用，使用本地文档目录
            let documentsDirectory = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!
            
            return documentsDirectory.appendingPathComponent(storeName)
        }
    }
}

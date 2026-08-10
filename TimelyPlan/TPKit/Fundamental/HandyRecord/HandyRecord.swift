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
    
    // MARK: - 变更计数与自动保存机制
    
    /// 当前未保存的变更计数
    private static var changeCount: Int = 0
    
    /// 触发自动保存的阈值，默认累积 10 次变更后自动保存
    static var autoSaveThreshold: Int = 10
    
    /// 自动保存定时器
    private static var autoSaveTimer: Timer?
    
    /// 自动保存的时间间隔（秒），默认 30 秒
    static var autoSaveInterval: TimeInterval = 60.0
    
    /// 是否有未保存的变更
    static var hasUnsavedChanges: Bool {
        return changeCount > 0
    }
    
    /// 用于线程安全的锁
    private static let changeCountLock = NSLock()
    
    /// 记录一次变更，增加变更计数
    /// - Note: 类似于 UIDocument.updateChangeCount() 的行为
    /// - Warning: 此方法线程安全，可在任意线程调用
    static func updateChangeCount() {
        changeCountLock.lock()
        changeCount += 1
        let currentCount = changeCount
        changeCountLock.unlock()
        
        // 检查是否达到自动保存阈值
        if currentCount >= autoSaveThreshold {
            performAutoSave()
        }
        
        #if DEBUG
        print("📝 变更计数: \(currentCount)/\(autoSaveThreshold)")
        #endif
    }
    
    /// 根据重要性增加变更计数
    /// - Parameter importance: 变更重要程度，1 为普通变更，5 为关键变更
    /// - Note: 关键变更会更快触发自动保存
    static func updateChangeCount(withImportance importance: Int) {
        let weight = max(1, min(importance, 10))  // 限制在 1-10 之间
        changeCountLock.lock()
        changeCount += weight
        let currentCount = changeCount
        changeCountLock.unlock()
        
        if currentCount >= autoSaveThreshold {
            performAutoSave()
        }
    }
    
    /// 执行自动保存
    private static func performAutoSave() {
        // 重置计数器
        resetChangeCountAndTimer()
        
        // 执行异步保存
        save { success, error in
            #if DEBUG
            if success {
                print("✅ 自动保存成功")
            } else {
                print("❌ 自动保存失败: \(error?.localizedDescription ?? "未知错误")")
            }
            #endif
        }
    }
    
    /// 重置变更计数
    static func resetChangeCountAndTimer() {
        changeCountLock.lock()
        changeCount = 0
        changeCountLock.unlock()
        
        /// 重新启动计时器
        startAutoSaveTimer()
    }
    
    // MARK: - 自动保存定时器管理
    
    /// 启动自动保存定时器
    /// - Note: 定时器会在指定间隔后检查是否有未保存的变更，如果有则执行保存
    static func startAutoSaveTimer() {
        stopAutoSaveTimer()
        
        autoSaveTimer = Timer.scheduledTimer(
            withTimeInterval: autoSaveInterval,
            repeats: true
        ) { _ in
            checkAndSaveIfNeeded()
        }
        
        // 允许定时器在滚动等场景下也能触发
        RunLoop.current.add(autoSaveTimer!, forMode: .common)
        
        #if DEBUG
        print("⏰ 自动保存定时器已启动，间隔: \(autoSaveInterval)秒")
        #endif
    }
    
    /// 停止自动保存定时器
    static func stopAutoSaveTimer() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
        
        #if DEBUG
        print("⏰ 自动保存定时器已停止")
        #endif
    }
    
    /// 检查并执行必要的保存
    private static func checkAndSaveIfNeeded() {
        guard hasUnsavedChanges else { return }
        
        #if DEBUG
        print("🔍 检测到未保存的变更，开始自动保存...")
        #endif
        
        performAutoSave()
    }
    
    /// 强制立即保存所有未保存的变更
    /// - Parameter completion: 保存完成回调
    static func forceSavePendingChanges(completion: ((Bool) -> Void)? = nil) {
        guard hasUnsavedChanges else {
            completion?(true)
            return
        }
        
        resetChangeCountAndTimer()
        
        save { success, error in
            completion?(success)
            if let error = error {
                debugPrint("❌ 强制保存失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: 异步保存操作
    
    /// 使用默认上下文进行异步保存
    /// - Parameter completion: 保存完成后的回调，在主线程执行
    class func save(completion: HandyRecordSaveCompletionHandler? = nil) {
        let defaultContext = NSManagedObjectContext.defaultContext
        defaultContext.saveWithOptions([.parentContexts], completion: completion)
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
            
            // 配置 CloudKit 数据同步管理器
            configureCloudKitSyncManager(with: container)
            
            // 启动自动保存定时器
            startAutoSaveTimer()
            
            completion(true)
        }
    }
    
    // MARK: - 应用生命周期集成
    
    /// 应用进入后台时调用，强制保存所有未保存的变更
    /// - Note: 应在 AppDelegate 或 SceneDelegate 的对应方法中调用
    static func applicationDidEnterBackground() {
        // 暂停定时器
        stopAutoSaveTimer()
        
        // 强制同步保存所有变更
        forceSavePendingChanges { success in
            #if DEBUG
            if success {
                print("✅ 后台保存成功")
            } else {
                print("❌ 后台保存失败")
            }
            #endif
        }
    }
    
    /// 应用回到前台时调用，恢复自动保存定时器
    /// - Note: 应在 AppDelegate 或 SceneDelegate 的对应方法中调用
    static func applicationWillEnterForeground() {
        startAutoSaveTimer()
    }

    // MARK: - 容器配置
    
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
    
    private static func configureCloudKitSyncManager(with container: NSPersistentCloudKitContainer) {
        let cloudKitSyncManager = CloudKitSyncManager.shared
        cloudKitSyncManager.configure(with: container)
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

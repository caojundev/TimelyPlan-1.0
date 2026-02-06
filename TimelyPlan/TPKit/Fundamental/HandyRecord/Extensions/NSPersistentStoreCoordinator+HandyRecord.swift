//
//  NSPersistentStoreCoordinator+HandyRecord.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

private var HandyRecordDefaultStoreCoordinator: NSPersistentStoreCoordinator!

extension NSPersistentStoreCoordinator {
    /// 默认持久化存储协调器
    static var defaultStoreCoordinator: NSPersistentStoreCoordinator {
        get {
//            if HandyRecordDefaultStoreCoordinator == nil &&
//                [MagicalRecord shouldAutoCreateDefaultPersistentStoreCoordinator])
//            {
//                [self MR_setDefaultStoreCoordinator:[self MR_newPersistentStoreCoordinator]];
//            }

            return HandyRecordDefaultStoreCoordinator
        }
        
        set {
            HandyRecordDefaultStoreCoordinator = newValue
            let stores = newValue.persistentStores
            if stores.count > 0 && NSPersistentStore.defaultPersistentStore == nil {
                NSPersistentStore.defaultPersistentStore = stores.first!
            }
        }
    }
    
    /*
    func addiCloudContainerID(_ containerID: String,
                              contentNameKey: String?,
                              storeIdentifier: Any,
                              cloudStorePathComponent: String?,
                              completion: (() -> Void)?) {
        // 检查 contentNameKey 是否包含句点（.）符号
        assert(contentNameKey == nil || !contentNameKey.contains("."), "NSPersistentStoreUbiquitousContentNameKey不能包含点符号")
        
        DispatchQueue.global().async {
            // 获取 iCloud 容器的 URL
            let cloudURL = NSPersistentStore.cloudURL(forUbiquityContainerIdentifier: kUbiquityContainerIdentifier)
            /// 设置是否启用 iCloud
            HandyRecord.isICloudEnabled = cloudURL != nil
            
            if let cloudURL = cloudURL {
                var url = cloudURL
                if let subPathComponent = cloudStorePathComponent {
                    /// 如果指定了 subPathComponent，则将其追加到 cloudURL 中
                    url = cloudURL.appendingPathComponent(subPathComponent)
                }
                
                
                /// 创建 iCloud 相关选项
                var iCloudOptions = [AnyHashable: Any]()
                iCloudOptions[NSPersistentStoreUbiquitousContentURLKey] = cloudURL
                
                if !contentNameKey.isEmpty {
                    iCloudOptions[NSPersistentStoreUbiquitousContentNameKey] = contentNameKey
                }
                
                var options = NSPersistentStore.autoMigrationOptions()
                options = options.merging(iCloudOptions, uniquingKeysWith: { $1 })
            } else {
                NSLog("iCloud is not enabled")
            }
            
            if responds(to: #selector(perform(_:))) {
                // 如果当前对象支持 perform 方法，则在当前上下文上执行添加存储的操作
                perform(#selector(performAndReturn), with: {
                    self.addSqliteStoreNamed(storeIdentifier, withOptions: options)
                })
            } else {
                // 加锁以防止并发操作
                self.lock()
                self.addSqliteStoreNamed(storeIdentifier, withOptions: options)
                // 解锁
                self.unlock()
            }
            
            DispatchQueue.main.async {
                // 设置默认持久化存储为添加的存储
                if NSPersistentStore.defaultPersistentStore() == nil {
                    NSPersistentStore.setDefaultPersistentStore(self.persistentStores.first)
                }
                
                completion?()
                
                // 发送通知表示 iCloud 设置完成
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kMagicalRecordPSCDidCompleteiCloudSetupNotification), object: nil)
            }
        }
    }
    */
    
}

//
//  NSPersistentStoreCoordinator+Setup.swift
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
}

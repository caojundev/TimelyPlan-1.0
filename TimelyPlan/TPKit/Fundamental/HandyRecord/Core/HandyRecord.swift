//
//  HandyRecord.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

class HandyRecord {
    
    /// 保存选项
    struct SaveOptions: OptionSet {
        
        let rawValue: UInt

        /// 空选项
        static let none = SaveOptions([])

        /// 当保存时，继续保存父级上下文，直到更改在持久化存储中出现
        static let parentContexts = SaveOptions(rawValue: 1 << 1)

        /// 执行同步保存，阻塞当前线程的执行，直到保存完成
        static let synchronously = SaveOptions(rawValue: 1 << 2)

        /// 执行同步保存，阻塞当前线程的执行，直到保存完成；异步保存根上下文
        static let synchronouslyExceptRootContext = SaveOptions(rawValue: 1 << 3)
    }
    
    // MARK: - Asynchronous saving
    class func save(completion: HandyRecordSaveCompletionHandler? = nil) {
        let defaultContext = NSManagedObjectContext.defaultContext
        defaultContext.saveWithOptions([.parentContexts], completion: completion)
    }
    
    
    class func save(block: HandyRecordSaveBlock?) {
        save(block: block, completion: nil)
    }
    
    class func save(block: HandyRecordSaveBlock? = nil, completion: HandyRecordSaveCompletionHandler?) {
        let savingContext: NSManagedObjectContext = .rootSavingContext
        let localContext: NSManagedObjectContext = .context(withParent: savingContext)
        localContext.perform {
            block?(localContext)
            localContext.saveWithOptions([.parentContexts], completion: completion)
        }
    }

    // MARK: - Synchronous saving
    class func save(blockAndWait block: HandyRecordSaveBlock?, completion: HandyRecordSaveCompletionHandler?) {
        let savingContext: NSManagedObjectContext = .rootSavingContext
        let localContext: NSManagedObjectContext = .context(withParent: savingContext)
        localContext.performAndWait {
            block?(localContext)
            localContext.saveWithOptions([.parentContexts, .synchronously], completion: completion)
        }
    }

}

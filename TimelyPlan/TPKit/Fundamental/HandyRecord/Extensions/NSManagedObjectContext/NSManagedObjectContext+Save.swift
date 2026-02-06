//
//  NSManagedObjectContext+Save.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/11.
//

import Foundation
import CoreData

/// 保存完成回调闭包
typealias HandyRecordSaveBlock = (_ localContext: NSManagedObjectContext) -> Void

extension NSManagedObjectContext {
    
    func save(block: HandyRecordSaveBlock?) {
        save(block: block, completion: nil)
    }
    
    func save(block: HandyRecordSaveBlock?, completion: HandyRecordSaveCompletionHandler?) {
        let localContext = NSManagedObjectContext.context(withParent: self)
        localContext.perform {
            block?(localContext)
            localContext.saveWithOptions([.parentContexts], completion: completion)
        }
    }

    // MARK: - Synchronous saving

    func save(blockAndWait block: HandyRecordSaveBlock?, completion: HandyRecordSaveCompletionHandler?) {
        let localContext = NSManagedObjectContext.context(withParent: self)
        localContext.performAndWait {
            block?(localContext)
            localContext.saveWithOptions([.parentContexts, .synchronously], completion: completion)
        }
    }
}

/// 保存完成回调闭包
typealias HandyRecordSaveCompletionHandler = (_ success: Bool, _ error: Error?) -> Void

extension NSManagedObjectContext {

    // 仅保存当前 context 的更改，异步执行
    func saveOnlySelf(completion: HandyRecordSaveCompletionHandler?) {
        saveWithOptions(.none, completion: completion)
    }

    // 仅保存当前 context 的更改，同步执行
    func saveOnlySelfAndWait() {
        saveWithOptions([.synchronously], completion: nil)
    }

    // 保存当前 context 所有更改，以及其 parent context 的更改，异步执行
    func saveToPersistentStore(completion: HandyRecordSaveCompletionHandler?) {
        saveWithOptions([.parentContexts], completion: completion)
    }

    // 保存当前 context 所有更改，以及其 parent context 的更改，同步执行
    func saveToPersistentStoreAndWait() {
        saveWithOptions([.parentContexts, .synchronously], completion: nil)
    }

    /// 将当前上下文中的所有更改保存到持久化存储中
    func saveWithOptions(_ saveOptions: HandyRecord.SaveOptions,
                            completion: HandyRecordSaveCompletionHandler?) {
        
        var hasChanges = false
        performAndWait {
            hasChanges = self.hasChanges
        }

        guard hasChanges else {
            if let completion = completion {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }

            return
        }

        let shouldSaveParentContexts = saveOptions.contains(.parentContexts)
        let shouldSaveSynchronously = saveOptions.contains(.synchronously)
        let shouldSaveSynchronouslyExceptRoot = saveOptions.contains(.synchronouslyExceptRootContext)

        let saveSynchronously =
            (shouldSaveSynchronously && !shouldSaveSynchronouslyExceptRoot) ||
            (shouldSaveSynchronouslyExceptRoot && (self != Self.rootSavingContext))

        let saveBlock = {
            debugPrint("→ Saving \(self.description)")
            debugPrint("→ Save Parents? \(shouldSaveParentContexts ? "YES" : "NO")")
            debugPrint("→ Save Synchronously? \(saveSynchronously ? "YES" : "NO")")

            var saveResult = false
            var error: Error?
            do {
                try self.save()
                saveResult = true
            } catch let aError {
                debugPrint("Unable to perform save: \(aError.localizedDescription)")
                error = aError
            }
            
            if saveResult, shouldSaveParentContexts, let parent = self.parent {
                // Add/remove the synchronous save option from the mask if necessary
                var modifiedOptions = saveOptions
                if saveSynchronously {
                    modifiedOptions.insert(.synchronously)
                } else {
                    modifiedOptions.remove(.synchronously)
                }

                // 保存父上下文
                parent.saveWithOptions(modifiedOptions, completion: completion)
            } else {
                if saveResult {
                    debugPrint("→ Finished saving \(self.description)")
                }

                if let completion = completion {
                    DispatchQueue.main.async {
                        completion(saveResult, error)
                    }
                }
            }
        }

        if saveSynchronously {
            performAndWait(saveBlock)
        } else {
            perform(saveBlock)
        }
    }
}



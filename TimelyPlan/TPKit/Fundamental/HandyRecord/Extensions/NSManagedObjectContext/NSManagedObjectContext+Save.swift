//
//  NSManagedObjectContext+Save.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/11.
//

import Foundation
import CoreData

// MARK: - 类型别名定义

/// 保存操作闭包
/// 在临时上下文中执行数据操作的闭包
/// - Parameter localContext: 用于执行操作的临时子上下文
typealias HandyRecordSaveBlock = (_ localContext: NSManagedObjectContext) -> Void

/// 保存完成回调闭包
/// - Parameters:
///   - success: 保存操作是否成功
///   - error: 保存失败时的错误信息，成功时为 nil
typealias HandyRecordSaveCompletionHandler = (_ success: Bool, _ error: Error?) -> Void

// MARK: - 便捷保存方法

extension NSManagedObjectContext {
    
    // MARK: 临时上下文操作
    
    /// 在临时子上下文中执行操作并异步保存
    /// - Parameter block: 在临时上下文中执行的操作闭包
    /// - Note: 适用于需要在独立上下文中执行数据操作的场景
    func save(block: HandyRecordSaveBlock?) {
        save(block: block, completion: nil)
    }
    
    /// 在临时子上下文中执行操作并异步保存，支持完成回调
    /// - Parameters:
    ///   - block: 在临时上下文中执行的操作闭包
    ///   - completion: 保存完成后的回调，在主线程执行
    /// - Note: 创建子上下文执行操作，保存后自动推送变更到父上下文
    func save(block: HandyRecordSaveBlock?, completion: HandyRecordSaveCompletionHandler?) {
        let localContext = NSManagedObjectContext.context(withParent: self)
        localContext.perform {
            // 在临时上下文中执行用户操作
            block?(localContext)
            
            // 保存临时上下文并级联保存父上下文
            localContext.saveWithOptions([.parentContexts], completion: completion)
        }
    }

    // MARK: 同步保存操作
    
    /// 在临时子上下文中执行操作并同步保存
    /// - Parameters:
    ///   - block: 在临时上下文中执行的操作闭包
    ///   - completion: 保存完成后的回调，在主线程执行
    /// - Warning: 使用 performAndWait 会阻塞当前线程，避免在主线程调用
    func save(blockAndWait block: HandyRecordSaveBlock?,
              completion: HandyRecordSaveCompletionHandler?) {
        let localContext = NSManagedObjectContext.context(withParent: self)
        localContext.performAndWait {
            // 在临时上下文中同步执行用户操作
            block?(localContext)
            
            // 同步保存临时上下文并级联保存父上下文
            localContext.saveWithOptions([.parentContexts, .synchronously], completion: completion)
        }
    }
}

// MARK: - 保存选项配置

extension NSManagedObjectContext {

    // MARK: 单一上下文保存
    
    /// 仅保存当前上下文的更改（异步执行）
    /// - Parameter completion: 保存完成回调
    /// - Note: 不会保存父上下文的更改，仅保存当前上下文的变更
    func saveOnlySelf(completion: HandyRecordSaveCompletionHandler?) {
        saveWithOptions(.none, completion: completion)
    }

    /// 仅保存当前上下文的更改（同步执行）
    /// - Warning: 会阻塞当前线程直到保存完成
    /// - Note: 不会保存父上下文的更改
    func saveOnlySelfAndWait() {
        saveWithOptions([.synchronously], completion: nil)
    }

    // MARK: 级联保存到持久化存储
    
    /// 保存当前上下文及其所有父上下文的更改（异步执行）
    /// - Parameter completion: 保存完成回调
    /// - Note: 级联保存直到根上下文，确保数据最终写入持久化存储
    func saveToPersistentStore(completion: HandyRecordSaveCompletionHandler?) {
        saveWithOptions([.parentContexts], completion: completion)
    }

    /// 保存当前上下文及其所有父上下文的更改（同步执行）
    /// - Warning: 会阻塞当前线程直到所有父上下文保存完成
    /// - Note: 级联保存直到根上下文，确保数据最终写入持久化存储
    func saveToPersistentStoreAndWait() {
        saveWithOptions([.parentContexts, .synchronously], completion: nil)
    }

    // MARK: 核心保存方法
    
    /// 使用指定的选项保存当前上下文的所有更改
    /// - Parameters:
    ///   - saveOptions: 保存选项，控制保存行为和范围
    ///   - completion: 保存完成回调，在主线程执行
    /// - Note: 该方法会递归保存父上下文，直到满足选项配置的终止条件
    func saveWithOptions(_ saveOptions: HandyRecord.SaveOptions,
                         completion: HandyRecordSaveCompletionHandler?) {
        
        // 检查是否有未保存的更改，避免不必要的保存操作
        var hasChanges = false
        performAndWait {
            hasChanges = self.hasChanges
        }

        guard hasChanges else {
            // 无更改时直接返回成功，避免空保存
            if let completion = completion {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
            return
        }

        // 解析保存选项
        let shouldSaveParentContexts = saveOptions.contains(.parentContexts)
        let shouldSaveSynchronously = saveOptions.contains(.synchronously)
        let shouldSaveSynchronouslyExceptRoot = saveOptions.contains(.synchronouslyExceptRootContext)

        // 确定是否使用同步保存模式
        // 1. 明确要求同步保存，且不是"除根上下文外同步"
        // 2. "除根上下文外同步"模式，且当前不是根上下文
        let saveSynchronously =
            (shouldSaveSynchronously && !shouldSaveSynchronouslyExceptRoot) ||
            (shouldSaveSynchronouslyExceptRoot && (self != Self.rootSavingContext))

        // 定义保存执行块
        let saveBlock = {
            // 调试日志（可根据需要取消注释）
            // debugPrint("→ 正在保存 \(self.description)")
            // debugPrint("→ 保存父上下文? \(shouldSaveParentContexts ? "是" : "否")")
            // debugPrint("→ 同步保存? \(saveSynchronously ? "是" : "否")")
            
            // 执行当前上下文的保存操作
            let saveResult = self.performContextSave()
            
            // 根据保存结果和选项决定是否继续保存父上下文
            if saveResult.success, shouldSaveParentContexts, let parent = self.parent {
                // 调整父上下文的保存选项，确保同步/异步模式正确传递
                var parentOptions = saveOptions
                if saveSynchronously {
                    parentOptions.insert(.synchronously)
                } else {
                    parentOptions.remove(.synchronously)
                }
                
                // 递归保存父上下文
                parent.saveWithOptions(parentOptions, completion: completion)
            } else {
                // 保存完成（无需保存父上下文或已是根上下文）
                if saveResult.success {
                    // debugPrint("→ 完成保存 \(self.description)")
                }
                
                // 在主线程回调保存结果
                if let completion = completion {
                    DispatchQueue.main.async {
                        completion(saveResult.success, saveResult.error)
                    }
                }
            }
        }

        // 根据同步/异步模式执行保存操作
        if saveSynchronously {
            performAndWait(saveBlock)
        } else {
            perform(saveBlock)
        }
    }
    
    // MARK: 私有辅助方法
    
    /// 执行当前上下文的保存操作
    /// - Returns: 包含保存结果和错误信息的元组
    private func performContextSave() -> (success: Bool, error: Error?) {
        do {
            try self.save()
            return (true, nil)
        } catch {
            debugPrint("保存失败: \(error.localizedDescription)")
            return (false, error)
        }
    }
}

//
//  NSManagedObjectContext+Observing.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

// MARK: - 常量定义

/// iCloud 变更合并完成通知
/// 当上下文完成合并来自 iCloud 的远程变更后发送
let kHandyRecordDidMergeChangesFromICloudNotification = Notification.Name(
    rawValue: "HandyRecordDidMergeChangesFromICloudNotification"
)

// MARK: - 上下文变更监听与合并

extension NSManagedObjectContext {
    
    // MARK: 上下文观察注册
    
    /// 观察其他上下文的保存通知，并在主线程合并变更
    /// - Parameter otherContext: 需要观察的目标上下文
    /// - Note: 适用于需要在主线程更新 UI 的场景
    func observeContextOnMainThread(_ otherContext: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mergeChangesOnMainThread(fromObjectsDidSave:)),
            name: Self.didSaveObjectsNotification,
            object: otherContext
        )
    }
    
    /// 观察其他上下文的保存通知（在当前线程合并变更）
    /// - Parameter otherContext: 需要观察的目标上下文
    /// - Note: 合并操作在通知所在的线程执行
    func observeContext(_ otherContext: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mergeChanges(fromObjectsDidSave:)),
            name: Self.didSaveObjectsNotification,
            object: otherContext
        )
    }
    
    /// 停止观察其他上下文的保存通知
    /// - Parameter otherContext: 需要移除观察的目标上下文
    func stopObservingContext(_ otherContext: NSManagedObjectContext) {
        NotificationCenter.default.removeObserver(
            self,
            name: Self.didSaveObjectsNotification,
            object: otherContext
        )
    }
    
    // MARK: 变更合并处理
    
    /// 合并其他上下文保存的变更到当前上下文
    /// - Parameter notification: 保存完成通知
    /// - Note: 该方法在收到通知的线程中执行
    @objc func mergeChanges(fromObjectsDidSave notification: Notification) {
        // 记录合并日志，标注是否为默认上下文和主线程
        let contextType = (self == Self.defaultContext) ? "*** DEFAULT *** " : ""
        let threadType = Thread.isMainThread ? " *** on Main Thread ***" : ""
        debugPrint("合并变更到 %@context%@", contextType, threadType)
        
        // 执行实际的变更合并
        mergeChanges(fromContextDidSave: notification)
    }
    
    /// 确保在主线程合并其他上下文的变更
    /// - Parameter notification: 保存完成通知
    /// - Note: 如果当前已在主线程则直接合并，否则调度到主线程并等待完成
    @objc func mergeChangesOnMainThread(fromObjectsDidSave notification: Notification) {
        if Thread.isMainThread {
            // 已在主线程，直接执行合并
            mergeChanges(fromObjectsDidSave: notification)
        } else {
            // 不在主线程，调度到主线程执行（同步等待，确保 UI 及时更新）
            performSelector(
                onMainThread: #selector(mergeChanges(fromObjectsDidSave:)),
                with: notification,
                waitUntilDone: true
            )
        }
    }
}

// MARK: - iCloud 远程变更处理

extension NSManagedObjectContext {
    
    // MARK: iCloud 监听注册
    
    /// 开始监听 iCloud 远程变更通知
    /// - Parameter coordinator: 持久化存储协调器
    /// - Note: 仅在 iCloud 同步启用时生效
    func observeICloudChanges(inCoordinator coordinator: NSPersistentStoreCoordinator) {
        guard HandyRecord.isICloudEnabled else {
            debugPrint("iCloud 同步未启用，跳过远程变更监听")
            return
        }
    
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mergeChanges(fromICloud:)),
            name: NSNotification.Name.NSPersistentStoreRemoteChange,
            object: coordinator
        )
    }

    /// 停止监听 iCloud 远程变更通知
    /// - Parameter coordinator: 持久化存储协调器
    func stopObservingICloudChanges(inCoordinator coordinator: NSPersistentStoreCoordinator) {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.NSPersistentStoreRemoteChange,
            object: coordinator
        )
    }

    // MARK: iCloud 变更合并
    
    /// 处理来自 iCloud 的远程变更通知
    /// - Parameter notification: iCloud 远程变更通知
    /// - Note:
    ///   - 在上下文的私有队列中执行合并，确保线程安全
    ///   - 合并完成后发送自定义通知，便于其他组件响应变更
    @objc private func mergeChanges(fromICloud notification: Notification) {
        // 在上下文所在的队列中执行合并操作
        perform {
            // 合并远程变更到当前上下文
            self.mergeChanges(fromContextDidSave: notification)
            
            // 发送自定义通知，通知其他组件 iCloud 数据已更新
            NotificationCenter.default.post(
                name: kHandyRecordDidMergeChangesFromICloudNotification,
                object: self,
                userInfo: notification.userInfo
            )
        }
    }
}

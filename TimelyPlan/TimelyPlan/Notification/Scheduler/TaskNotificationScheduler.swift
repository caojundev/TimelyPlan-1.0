//
//  TaskNotificationScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/22.
//

import Foundation
import UIKit

// MARK: - 任务通知计划器
class TaskNotificationScheduler {
    
    // MARK: - 错误定义
    enum SchedulerError: LocalizedError {
        case operationCancelled
        case permissionDenied
        
        var errorDescription: String? {
            switch self {
            case .operationCancelled: return "操作已取消"
            case .permissionDenied: return "通知权限被拒绝"
            }
        }
    }
    
    // MARK: - 单例
    static let shared = TaskNotificationScheduler()
    
    // MARK: - 依赖
    private let notificationManager = TaskNotificationManager.shared
    
    // MARK: - 任务获取器
    private var fetcher = LocalNotifiableTaskFetcher()
    
    // MARK: - 操作管理
    private var currentFetchOperation: CancellableOperation?
    private let operationLock = NSLock()
    
    // MARK: - 防抖
    private var debounceWorkItem: DispatchWorkItem?
    private var debounceInterval: TimeInterval = 0.5
    
    // MARK: - 配置
    /// 是否启用应用生命周期自动刷新
    var enableAutoRefresh: Bool = true
    /// 防抖间隔（秒）
    var refreshDebounceInterval: TimeInterval = 0.5 {
        didSet { debounceInterval = refreshDebounceInterval }
    }
    
    // MARK: - 初始化
    private init() {
        observeAppLifecycle()
        fetcher.onTaskChanged = { [weak self] in
            self?.refreshTasks()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 应用生命周期
    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidBecomeActive() {
        guard enableAutoRefresh else { return }
        refreshTasks()
    }
    
    // MARK: - 刷新任务（核心方法）
    
    /// 立即刷新（取消上一次未完成的操作）
    func refreshTasks(completion: ((Result<Int, Error>) -> Void)? = nil) {
        // 取消上一次操作
        cancelCurrentFetch()
        
        // 创建新操作
        let operation = CancellableOperation()
        setCurrentFetchOperation(operation)
        
//        debugPrint("🔄 开始获取任务...")
        // 调用 provider 获取任务
        fetcher.fetchNotifiableTasks { [weak self] tasks in
            guard let self = self else { return }
            
            guard !operation.isCancelled else {
                self.callbackOnMain(completion, result: .failure(SchedulerError.operationCancelled))
                return
            }
            
//            print("📥 获取到 \(tasks.count) 个任务")
            
            // 注册通知
            self.notificationManager.schedule(tasks) { result in
//                switch result {
//                case .success(let count):
//                    print("✅ 通知注册完成: \(count)个")
//                case .failure(let error):
//                    print("❌ 通知注册失败: \(error)")
//                }
//
                self.callbackOnMain(completion, result: result)
            }
        }
    }
    
    /// 防抖刷新（适合频繁调用场景）
    func refreshTasksWithDebounce(completion: ((Result<Int, Error>) -> Void)? = nil) {
        debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.refreshTasks(completion: completion)
        }
        debounceWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval,
                                      execute: workItem)
    }
    
    // MARK: - 操作管理
    private func cancelCurrentFetch() {
        operationLock.lock()
        currentFetchOperation?.cancel()
        operationLock.unlock()
    }
    
    private func setCurrentFetchOperation(_ operation: CancellableOperation) {
        operationLock.lock()
        currentFetchOperation = operation
        operationLock.unlock()
    }
    
    // MARK: - 便捷方法
    func requestPermissionAndRefresh(completion: ((Result<Int, Error>) -> Void)? = nil) {
        notificationManager.requestAuthorization { [weak self] granted in
            guard granted else {
                completion?(.failure(SchedulerError.permissionDenied))
                return
            }
            self?.refreshTasks(completion: completion)
        }
    }
    
    // MARK: - 辅助方法
    private func callbackOnMain(_ completion: ((Result<Int, Error>) -> Void)?, result: Result<Int, Error>) {
        DispatchQueue.main.async {
            completion?(result)
        }
    }
    
}

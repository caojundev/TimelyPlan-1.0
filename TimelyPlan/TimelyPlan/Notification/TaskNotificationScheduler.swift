//
//  TaskNotificationScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/22.
//

import Foundation
import UIKit

// MARK: - 任务提供者协议
protocol TaskProvider: AnyObject {
    /// 异步获取任务，通过 completion 返回
    /// - Parameter completion: 任务数组的回调（在主线程或任意线程调用均可）
    func fetchTasks(completion: @escaping ([ScheduledTask]) -> Void)
}

// MARK: - 任务生命周期管理器
class TaskLifecycleManager {
    
    // MARK: - 单例
    static let shared = TaskLifecycleManager()
    
    // MARK: - 依赖
    private let notificationManager = TaskNotificationManager.shared
    
    // MARK: - Provider
    private var provider: TaskProvider?
    private let providerLock = NSLock()
    
    // MARK: - 队列
    private let queue = DispatchQueue(label: "task.lifecycle.manager", qos: .utility)
    
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
    
    // MARK: - Provider 管理
    func setProvider(_ provider: TaskProvider) {
        providerLock.lock()
        self.provider = provider
        providerLock.unlock()
    }
    
    func removeProvider() {
        providerLock.lock()
        self.provider = nil
        providerLock.unlock()
    }
    
    private func getProvider() -> TaskProvider? {
        providerLock.lock()
        defer { providerLock.unlock() }
        return provider
    }
    
    // MARK: - 刷新任务（核心方法）
    
    /// 立即刷新（取消上一次未完成的操作）
    func refreshTasks(completion: ((Result<Int, Error>) -> Void)? = nil) {
        // 取消上一次操作
        cancelCurrentFetch()
        
        // 创建新操作
        let operation = CancellableOperation()
        setCurrentFetchOperation(operation)
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 获取 provider
            guard let provider = self.getProvider() else {
                print("⚠️ 未设置 TaskProvider")
                self.callbackOnMain(completion, result: .failure(LifecycleError.noProvider))
                return
            }
            
            guard !operation.isCancelled else {
                self.callbackOnMain(completion, result: .failure(LifecycleError.operationCancelled))
                return
            }
            
            print("🔄 开始获取任务...")
            
            // 调用 provider 获取任务
            provider.fetchTasks { [weak self] tasks in
                guard let self = self else { return }
                
                guard !operation.isCancelled else {
                    self.callbackOnMain(completion, result: .failure(LifecycleError.operationCancelled))
                    return
                }
                
                print("📥 获取到 \(tasks.count) 个任务")
                
                // 注册通知
                self.notificationManager.schedule(tasks) { result in
                    switch result {
                    case .success(let count):
                        print("✅ 通知注册完成: \(count)个")
                    case .failure(let error):
                        print("❌ 通知注册失败: \(error)")
                    }
                    
                    self.callbackOnMain(completion, result: result)
                }
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
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
    
    // MARK: - 辅助方法
    private func callbackOnMain(_ completion: ((Result<Int, Error>) -> Void)?, result: Result<Int, Error>) {
        DispatchQueue.main.async {
            completion?(result)
        }
    }
    
    // MARK: - 便捷方法
    func requestPermissionAndRefresh(completion: ((Result<Int, Error>) -> Void)? = nil) {
        notificationManager.requestAuthorization { [weak self] granted in
            guard granted else {
                completion?(.failure(LifecycleError.permissionDenied))
                return
            }
            self?.refreshTasks(completion: completion)
        }
    }
}

// MARK: - 错误定义
enum LifecycleError: LocalizedError {
    case operationCancelled
    case noProvider
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .operationCancelled: return "操作已取消"
        case .noProvider: return "未设置 TaskProvider"
        case .permissionDenied: return "通知权限被拒绝"
        }
    }
}


// 实现 TaskProvider
class MyTaskProvider: TaskProvider {
    
    // 示例任务
    struct DailyReminderTask: ScheduledTask {
        let taskIdentifier = "daily_reminder"
        
        func getNotificationConfigs() -> [TaskNotificationConfig] {
            var configs: [TaskNotificationConfig] = []
            let calendar = Calendar.current
            
            for day in 1...5 {
                if let date = calendar.date(byAdding: .day, value: day, to: Date()) {
                    var comps = calendar.dateComponents([.year, .month, .day], from: date)
                    comps.hour = 9
                    comps.minute = 0
                    if let triggerDate = calendar.date(from: comps) {
                        configs.append(TaskNotificationConfig(
                            taskIdentifier: taskIdentifier,
                            title: "📝 每日提醒",
                            body: "完成今天的任务",
                            triggerDate: triggerDate,
                            badge: 1
                        ))
                    }
                }
            }
            return configs
        }
    }

    struct MeetingReminderTask: ScheduledTask {
        let taskIdentifier = "meeting_reminder"
        
        func getNotificationConfigs() -> [TaskNotificationConfig] {
            var configs: [TaskNotificationConfig] = []
            let calendar = Calendar.current
            
            for week in 0..<2 {
                for weekday in [3, 5] {
                    var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
                    comps.weekOfYear! += week
                    comps.weekday = weekday
                    comps.hour = 10
                    comps.minute = 0
                    if let triggerDate = calendar.date(from: comps), triggerDate > Date() {
                        configs.append(TaskNotificationConfig(
                            taskIdentifier: taskIdentifier,
                            title: "💼 周会",
                            body: "15分钟后开始",
                            triggerDate: triggerDate
                        ))
                    }
                }
            }
            return configs
        }
    }
    
    func fetchTasks(completion: @escaping ([ScheduledTask]) -> Void) {
        // 模拟异步获取任务（网络请求、数据库查询等）
        DispatchQueue.global().async {
            // 模拟耗时操作
            Thread.sleep(forTimeInterval: 0.5)
            
            // 返回任务
            let tasks: [ScheduledTask] = [
                DailyReminderTask(),
                MeetingReminderTask()
            ]
            
            completion(tasks)
        }
    }
}

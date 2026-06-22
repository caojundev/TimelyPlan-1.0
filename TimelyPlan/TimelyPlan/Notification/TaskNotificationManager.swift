//
//  TaskNotificationManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/10.
//

import UserNotifications
import Foundation
import UIKit

// MARK: - 任务协议
protocol ScheduledTask {
    var taskIdentifier: String { get }
    func getNotificationConfigs() -> [TaskNotificationConfig]
}

// MARK: - 时间冲突策略
enum TimeConflictStrategy {
    case skip
    case shift(seconds: TimeInterval)
    case merge
}

// MARK: - 可取消的调度操作
class CancellableOperation: @unchecked Sendable {
    private var _isCancelled = false
    private let lock = NSLock()
    
    var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isCancelled
    }
    
    func cancel() {
        lock.lock()
        _isCancelled = true
        lock.unlock()
    }
    
    func checkCancelled() throws {
        if isCancelled {
            throw NotificationError.operationCancelled
        }
    }
}

// MARK: - 通知管理器
class TaskNotificationManager: NSObject, @unchecked Sendable {
    
    static let shared = TaskNotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let maxNotifications = 60
    
    // 串行队列保证操作顺序
    private let serialQueue = DispatchQueue(label: "notification.manager.serial", qos: .utility)
    
    // 当前正在执行的操作
    private var currentOperation: CancellableOperation?
    private let operationLock = NSLock()
    
    // 版本号
    private var schedulingVersion: Int64 = 0
    private var latestScheduledVersion: Int64 = 0
    
    // 最后一次成功调度的任务快照
    private var lastScheduledTasks: [ScheduledTask] = []
    private let tasksLock = NSLock()
    
    // 防抖配置
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 0.3
    
    // 配置
    var conflictStrategy: TimeConflictStrategy = .shift(seconds: 300)
    var conflictThreshold: TimeInterval = 60
    var enableDebounce: Bool = true
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        observeLifecycle()
    }
    
    private func observeLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidBecomeActive() {
        refreshWithLastKnownTasks()
    }
    
    // MARK: - 权限
    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    // MARK: - 核心方法：支持取消和防抖的调度
    
    /// 调度任务（带防抖）
    func scheduleWithDebounce(_ tasks: [ScheduledTask], completion: ((Result<Int, Error>) -> Void)? = nil) {
        guard enableDebounce else {
            schedule(tasks, completion: completion)
            return
        }
        
        debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.schedule(tasks, completion: completion)
        }
        debounceWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
    }
    
    /// 立即调度任务（取消上一次未完成的操作）
    func schedule(_ tasks: [ScheduledTask], completion: ((Result<Int, Error>) -> Void)? = nil) {
        // 取消上一次操作
        cancelCurrentOperation()
        
        // 递增版本号
        let thisVersion = incrementVersion()
        
        // 保存任务快照
        saveTaskSnapshot(tasks)
        
        // 创建新的可取消操作
        let operation = CancellableOperation()
        setCurrentOperation(operation)
        
        // 修复：使用 Task 包裹异步代码
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 创建 Task 来处理异步操作
            Task {
                do {
                    // 检查是否已被取消
                    try operation.checkCancelled()
                    
                    // 1. 收集所有配置
                    let allConfigs = tasks.flatMap { task -> [TaskNotificationConfig] in
                        Array(task.getNotificationConfigs().prefix(5))
                    }
                    
                    try operation.checkCancelled()
                    
                    // 2. 过滤 + 排序
                    let now = Date()
                    let validConfigs = allConfigs
                        .filter { $0.triggerDate > now }
                        .sorted { $0.triggerDate < $1.triggerDate }
                    
                    try operation.checkCancelled()
                    
                    // 3. 冲突处理
                    let resolvedConfigs = self.resolveConflicts(validConfigs)
                    
                    try operation.checkCancelled()
                    
                    // 4. 截取
                    let finalConfigs = Array(resolvedConfigs.prefix(self.maxNotifications))
                    
                    // 5. 检查版本号
                    guard thisVersion >= self.latestScheduledVersion else {
                        throw NotificationError.operationCancelled
                    }
                    
                    // 6. 全量替换
                    try await self.replaceAllNotifications(finalConfigs, operation: operation)
                    
                    // 7. 更新版本号
                    self.completeVersion(thisVersion)
                    
                    print("✅ 调度完成 v\(thisVersion): \(finalConfigs.count)个通知")
                    
                    DispatchQueue.main.async {
                        completion?(.success(finalConfigs.count))
                    }
                    
                } catch NotificationError.operationCancelled {
                    print("🛑 调度取消 v\(thisVersion)")
                    DispatchQueue.main.async {
                        completion?(.failure(NotificationError.operationCancelled))
                    }
                } catch {
                    print("❌ 调度失败 v\(thisVersion): \(error)")
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                }
            }
        }
    }
    
    /// 异步版本
    func schedule(_ tasks: [ScheduledTask]) async -> Result<Int, Error> {
        return await withCheckedContinuation { continuation in
            schedule(tasks) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    // MARK: - 取消操作
    private func cancelCurrentOperation() {
        operationLock.lock()
        let operation = currentOperation
        operationLock.unlock()
        
        if let operation = operation {
            operation.cancel()
            print("🛑 取消上一次调度操作")
        }
    }
    
    private func setCurrentOperation(_ operation: CancellableOperation) {
        operationLock.lock()
        currentOperation = operation
        operationLock.unlock()
    }
    
    // MARK: - 版本控制
    private func incrementVersion() -> Int64 {
        schedulingVersion += 1
        return schedulingVersion
    }
    
    private func completeVersion(_ version: Int64) {
        if version > latestScheduledVersion {
            latestScheduledVersion = version
        }
    }
    
    // MARK: - 任务快照
    private func saveTaskSnapshot(_ tasks: [ScheduledTask]) {
        tasksLock.lock()
        lastScheduledTasks = tasks
        tasksLock.unlock()
    }
    
    private func refreshWithLastKnownTasks() {
        tasksLock.lock()
        let tasks = lastScheduledTasks
        tasksLock.unlock()
        
        if !tasks.isEmpty {
            print("🔄 使用最后成功的任务刷新通知")
            schedule(tasks)
        }
    }
    
    // MARK: - 冲突处理
    private func resolveConflicts(_ configs: [TaskNotificationConfig]) -> [TaskNotificationConfig] {
        guard configs.count > 1 else { return configs }
        
        var resolved: [TaskNotificationConfig] = []
        
        for config in configs {
            if resolved.isEmpty {
                resolved.append(config)
                continue
            }
            
            let lastConfig = resolved.last!
            let interval = config.triggerDate.timeIntervalSince(lastConfig.triggerDate)
            
            if interval < conflictThreshold {
                switch conflictStrategy {
                case .skip:
                    continue
                    
                case .shift(let seconds):
                    let newDate = lastConfig.triggerDate.addingTimeInterval(seconds)
                    let shiftedConfig = TaskNotificationConfig(
                        taskIdentifier: config.taskIdentifier,
                        title: config.title,
                        body: config.body,
                        triggerDate: newDate,
                        sound: config.sound,
                        badge: config.badge,
                        userInfo: config.userInfo
                    )
                    shiftedConfig.categoryIdentifier = config.categoryIdentifier
                    resolved.append(shiftedConfig)
                    
                case .merge:
                    let merged = TaskNotificationConfig(
                        taskIdentifier: lastConfig.taskIdentifier,
                        title: "\(lastConfig.title) & \(config.title)",
                        body: "\(lastConfig.body)\n\(config.body)",
                        triggerDate: lastConfig.triggerDate,
                        sound: lastConfig.sound,
                        badge: lastConfig.badge,
                        userInfo: ["merged": true]
                    )
                    resolved[resolved.count - 1] = merged
                }
            } else {
                resolved.append(config)
            }
        }
        
        return resolved
    }
    
    // MARK: - 全量替换（支持取消检查）
    private func replaceAllNotifications(_ configs: [TaskNotificationConfig], operation: CancellableOperation) async throws {
        // 删除所有现有通知
        notificationCenter.removeAllPendingNotificationRequests()
        
        try operation.checkCancelled()
        
        // 使用 TaskGroup 并发添加通知
        try await withThrowingTaskGroup(of: Void.self) { group in
            for config in configs {
                group.addTask {
                    try operation.checkCancelled()
                    
                    let content = config.toNotificationContent()
                    let trigger = config.toNotificationTrigger()
                    let request = UNNotificationRequest(
                        identifier: config.notificationId,
                        content: content,
                        trigger: trigger
                    )
                    
                    try await UNUserNotificationCenter.current().add(request)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    // MARK: - 便捷方法
    func removeAll() {
        cancelCurrentOperation()
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func pendingCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }
    
    func printStatus() {
        Task {
            let requests = await notificationCenter.pendingNotificationRequests()
            print("""
            
            ═══════════ 通知管理器状态 ═══════════
            系统通知: \(requests.count)/\(maxNotifications)
            调度版本: v\(latestScheduledVersion)
            防抖: \(enableDebounce ? "开启(\(debounceInterval)s)" : "关闭")
            冲突策略: \(conflictStrategy)
            
            通知信息：
            \(requests.map { req in
                let taskId = req.content.userInfo["taskIdentifier"] as? String ?? "?"
                let title = req.content.title
                let trigger = (req.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
                return "  \(trigger?.formatted ?? "?") | \(taskId) | \(title)"
            }.joined(separator: "\n"))
            ═══════════════════════════════════════
            
            """)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension TaskNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let taskIdentifier = response.notification.request.content.userInfo["taskIdentifier"] as? String
        NotificationCenter.default.post(
            name: .taskNotificationTapped,
            object: nil,
            userInfo: ["taskIdentifier": taskIdentifier ?? ""]
        )
        completionHandler()
    }
}

extension Notification.Name {
    static let taskNotificationTapped = Notification.Name("TaskNotificationTapped")
}

// MARK: - 错误定义
enum NotificationError: LocalizedError {
    case operationCancelled
    case exceededLimit
    case schedulingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .operationCancelled: return "操作已取消"
        case .exceededLimit: return "超过通知数量限制"
        case .schedulingFailed(let reason): return "调度失败: \(reason)"
        }
    }
}

// MARK: - Date 扩展
extension Date {
    var formatted: String {
        let f = DateFormatter()
        f.dateFormat = "MM-dd HH:mm:ss"
        return f.string(from: self)
    }
}

// MARK: - 测试
class LocalNotificationTester {

    // MARK: - 使用示例（与之前相同）
    struct DailyTask: ScheduledTask {
        let taskIdentifier = "daily_task"
        
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

    struct MeetingTask: ScheduledTask {
        let taskIdentifier = "meeting_task"
        
        func getNotificationConfigs() -> [TaskNotificationConfig] {
            var configs: [TaskNotificationConfig] = []
            let calendar = Calendar.current
            
            for week in 0..<3 {
                for weekday in [3, 5] {
                    var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
                    comps.weekOfYear! += week
                    comps.weekday = weekday
                    comps.hour = 10
                    comps.minute = 0
                    if let triggerDate = calendar.date(from: comps), triggerDate > Date() {
                        configs.append(TaskNotificationConfig(
                            taskIdentifier: taskIdentifier,
                            title: "💼 会议",
                            body: "15分钟后开始",
                            triggerDate: triggerDate
                        ))
                    }
                }
            }
            return configs
        }
    }
    
    /// 模拟快速连续调用
    static func runConcurrencyTest() {
        let manager = TaskNotificationManager.shared
        manager.requestAuthorization { granted in
            guard granted else { return }
            
            // 测试快速连续调用
            for i in 1...5 {
                let delay = Double(i) * 0.1
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let tasks: [ScheduledTask] = [DailyTask(), MeetingTask()]
                    manager.schedule(tasks) { result in
                        switch result {
                        case .success(let count):
                            print("✅ 第\(i)次调度: \(count)个通知")
                        case .failure(let error):
                            print("❌ 第\(i)次调度失败: \(error)")
                        }
                    }
                }
            }
            
            // 最终状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                manager.printStatus()
            }
        }
    }

}

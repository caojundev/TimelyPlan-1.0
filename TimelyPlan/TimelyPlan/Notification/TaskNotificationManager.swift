//
//  TaskNotificationManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/10.
//

import UserNotifications
import Foundation
import UIKit

// MARK: - 通知配置封装类
class TaskNotificationConfig {
    let identifier: String
    let title: String
    let body: String
    var sound: UNNotificationSound?
    var badge: NSNumber?
    var userInfo: [String: Any]
    var categoryIdentifier: String?
    var threadIdentifier: String?
    var attachments: [UNNotificationAttachment]?
    let triggerDate: Date
    
    init(identifier: String,
         title: String,
         body: String,
         triggerDate: Date,
         sound: UNNotificationSound? = .default,
         badge: NSNumber? = nil,
         userInfo: [String: Any] = [:]) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.triggerDate = triggerDate
        self.sound = sound
        self.badge = badge
        self.userInfo = userInfo
    }
    
    func toNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        if let sound = sound {
            content.sound = sound
        }
        if let badge = badge {
            content.badge = badge
        }
        if let categoryIdentifier = categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        if let threadIdentifier = threadIdentifier {
            content.threadIdentifier = threadIdentifier
        }
        
        var enhancedUserInfo = userInfo
        enhancedUserInfo["taskIdentifier"] = identifier
        enhancedUserInfo["triggerDate"] = triggerDate.timeIntervalSince1970
        enhancedUserInfo["timestamp"] = Date().timeIntervalSince1970
        content.userInfo = enhancedUserInfo
        
        if let attachments = attachments {
            content.attachments = attachments
        }
        
        return content
    }
    
    func toNotificationTrigger() -> UNNotificationTrigger {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
}

// MARK: - 任务优先级
enum TaskPriority: Int, Comparable {
    case critical = 0
    case high = 1
    case normal = 2
    case low = 3
    
    static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - 简化的任务协议
protocol ScheduledTask {
    var taskIdentifier: String { get }
    var priority: TaskPriority { get }
    func getNotificationConfigs() -> [TaskNotificationConfig]
}

extension ScheduledTask {
    var priority: TaskPriority { .normal }
}

// MARK: - 时间冲突解决策略
enum TimeConflictStrategy {
    case keepEarliest           // 保留最早的通知
    case keepLatest             // 保留最晚的通知
    case keepHighestPriority    // 保留优先级最高的
    case merge                  // 合并内容
    case shift(minutes: Int)    // 偏移指定分钟
    case notify                 // 通知冲突但不处理
}

// MARK: - 滚动窗口通知管理器
class TaskNotificationManager: NSObject {
    
    // MARK: - 单例
    static let shared = TaskNotificationManager()
    
    // MARK: - 属性
    private let notificationCenter = UNUserNotificationCenter.current()
    private let maxSystemNotifications = 64
    private let reservedSlots = 10
    private let queue = DispatchQueue(label: "com.task.notification.manager", qos: .utility)
    
    // 滚动窗口配置
    private let rollingWindowSize = 20  // 最多同时向系统注册20条通知
    private let minWindowThreshold = 8   // 当通知少于8条时触发补位
    
    // 任务注册表
    private var taskRegistry: [String: ScheduledTask] = [:]
    
    // 已调度通知追踪
    private var scheduledNotificationIds: Set<String> = []
    private var notificationTaskMap: [String: String] = [:]  // notificationId -> taskIdentifier
    
    // 冲突处理配置
    private var conflictStrategy: TimeConflictStrategy = .shift(minutes: 5)
    private var timeGranularity: TimeInterval = 60  // 时间冲突检测粒度（秒）
    
    // 维护状态
    private var lastMaintenanceTime: Date = .distantPast
    private let maintenanceInterval: TimeInterval = 3600  // 1小时
    
    // MARK: - 初始化
    private override init() {
        super.init()
        notificationCenter.delegate = self
        setupDefaultCategories()
        observeAppLifecycle()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 通知分类设置
    private func setupDefaultCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "完成",
            options: .foreground
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "稍后提醒",
            options: []
        )
        
        let defaultCategory = UNNotificationCategory(
            identifier: "DEFAULT_TASK",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        notificationCenter.setNotificationCategories([defaultCategory])
    }
    
    func registerNotificationCategory(_ category: UNNotificationCategory) {
        notificationCenter.getNotificationCategories { categories in
            var updatedCategories = categories
            updatedCategories.insert(category)
            self.notificationCenter.setNotificationCategories(updatedCategories)
        }
    }
    
    // MARK: - 应用生命周期观察
    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidBecomeActive() {
        performRollingWindowMaintenance()
    }
    
    @objc private func applicationDidEnterBackground() {
        // 进入后台前确保关键任务有足够通知
        ensureCriticalTasksCoverage()
    }
    
    @objc private func applicationWillTerminate() {
        // 保存状态
        saveState()
    }
    
    // MARK: - 权限管理
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
            if let error = error {
                print("❌ 通知权限请求失败: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                if granted {
                    print("✅ 通知权限已获取")
                } else {
                    print("⚠️ 通知权限被拒绝")
                }
                completion(granted)
            }
        }
    }
    
    func checkAuthorizationStatus() -> UNAuthorizationStatus {
        var status: UNAuthorizationStatus = .notDetermined
        let semaphore = DispatchSemaphore(value: 0)
        notificationCenter.getNotificationSettings { settings in
            status = settings.authorizationStatus
            semaphore.signal()
        }
        semaphore.wait()
        return status
    }
    
    // MARK: - 核心方法：注册任务
    func registerTask(_ task: ScheduledTask, completion: @escaping (Result<Int, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let identifier = task.taskIdentifier
            
            // 验证任务
            guard !identifier.isEmpty else {
                DispatchQueue.main.async {
                    completion(.failure(NotificationError.invalidTask))
                }
                return
            }
            
            // 注册任务
            self.taskRegistry[identifier] = task
            
            // 立即执行滚动窗口调度
            self.performRollingWindowScheduling(for: task) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    // MARK: - 滚动窗口调度（核心算法）
    private func performRollingWindowScheduling(for task: ScheduledTask, completion: @escaping (Result<Int, Error>) -> Void) {
        // 1. 获取任务的所有通知配置
        let allConfigs = task.getNotificationConfigs()
        
        guard !allConfigs.isEmpty else {
            completion(.failure(NotificationError.noValidDates))
            return
        }
        
        // 2. 获取当前系统通知数量
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            
            let currentCount = requests.count
            let availableSlots = self.maxSystemNotifications - currentCount - self.reservedSlots
            
            guard availableSlots > 0 else {
                completion(.failure(NotificationError.exceededLimit))
                return
            }
            
            // 3. 合并所有任务的配置（当前任务的 + 其他已注册任务的）
            var allTaskConfigs: [TaskNotificationConfig] = []
            
            // 添加其他任务的配置（排除当前任务）
            for (otherId, otherTask) in self.taskRegistry where otherId != task.taskIdentifier {
                allTaskConfigs.append(contentsOf: otherTask.getNotificationConfigs())
            }
            
            // 添加当前任务的配置
            allTaskConfigs.append(contentsOf: allConfigs)
            
            // 4. 过滤并排序（只保留未来的通知）
            let now = Date()
            let futureConfigs = allTaskConfigs
                .filter { $0.triggerDate > now }
                .sorted { $0.triggerDate < $1.triggerDate }
            
            // 5. 解决时间冲突
            let resolvedConfigs = self.resolveTimeConflicts(futureConfigs)
            
            // 6. 应用滚动窗口（取最近的 N 条）
            let windowSize = min(self.rollingWindowSize, availableSlots)
            let windowedConfigs = Array(resolvedConfigs.prefix(windowSize))
            
            // 7. 移除不在窗口内的旧通知
            self.removeNotificationsOutsideWindow(windowedConfigs, for: task.taskIdentifier)
            
            // 8. 批量创建窗口内的通知
            self.createNotificationsInWindow(windowedConfigs, for: task) { result in
                switch result {
                case .success(let count):
                    print("🪟 滚动窗口调度完成: 窗口大小=\(windowSize), 实际创建=\(count)")
                    
                    // 9. 更新追踪信息
                    self.updateSchedulingTracker(windowedConfigs, taskIdentifier: task.taskIdentifier)
                    
                    completion(.success(count))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - 时间冲突解决
    private func resolveTimeConflicts(_ configs: [TaskNotificationConfig]) -> [TaskNotificationConfig] {
        guard configs.count > 1 else { return configs }
        
        var resolved: [TaskNotificationConfig] = []
        var currentGroup: [TaskNotificationConfig] = []
        
        for config in configs {
            if currentGroup.isEmpty {
                currentGroup.append(config)
                continue
            }
            
            // 检查是否与当前组的最后一个配置冲突
            let lastConfig = currentGroup.last!
            let timeDifference = abs(lastConfig.triggerDate.timeIntervalSince(config.triggerDate))
            
            if timeDifference < timeGranularity {
                // 时间冲突，加入当前组
                currentGroup.append(config)
            } else {
                // 无冲突，解决当前组并开始新组
                resolved.append(contentsOf: resolveConflictGroup(currentGroup))
                currentGroup = [config]
            }
        }
        
        // 处理最后一组
        if !currentGroup.isEmpty {
            resolved.append(contentsOf: resolveConflictGroup(currentGroup))
        }
        
        return resolved.sorted { $0.triggerDate < $1.triggerDate }
    }
    
    private func resolveConflictGroup(_ group: [TaskNotificationConfig]) -> [TaskNotificationConfig] {
        guard group.count > 1 else { return group }
        
        print("⚠️ 检测到时间冲突: \(group.count) 个通知在相近时间")
        
        switch conflictStrategy {
        case .keepEarliest:
            return [group.first!]
            
        case .keepLatest:
            return [group.last!]
            
        case .keepHighestPriority:
            return [selectHighestPriority(from: group)]
            
        case .merge:
            return [mergeConfigs(group)]
            
        case .shift(let minutes):
            return shiftConfigs(group, minutes: minutes)
            
        case .notify:
            handleConflictNotification(group)
            return group  // 保持原样，但发出通知
        }
    }
    
    private func selectHighestPriority(from group: [TaskNotificationConfig]) -> TaskNotificationConfig {
        // 根据任务优先级选择
        var bestConfig = group[0]
        var bestPriority = TaskPriority.low
        
        for config in group {
            if let task = taskRegistry[config.identifier] {
                if task.priority < bestPriority {
                    bestPriority = task.priority
                    bestConfig = config
                }
            }
        }
        
        return bestConfig
    }
    
    private func mergeConfigs(_ group: [TaskNotificationConfig]) -> TaskNotificationConfig {
        // 合并多个通知的内容
        let primary = group[0]
        let mergedTitle = group.map { $0.title }.joined(separator: " & ")
        let mergedBody = group.map { $0.body }.joined(separator: "\n")
        
        return TaskNotificationConfig(
            identifier: primary.identifier,
            title: mergedTitle,
            body: mergedBody,
            triggerDate: primary.triggerDate,
            sound: primary.sound,
            badge: primary.badge,
            userInfo: ["merged": true, "count": group.count]
        )
    }
    
    private func shiftConfigs(_ group: [TaskNotificationConfig], minutes: Int) -> [TaskNotificationConfig] {
        // 按优先级排序，依次偏移
        var shifted: [TaskNotificationConfig] = []
        let sorted = group.sorted { config1, config2 in
            let priority1 = taskRegistry[config1.identifier]?.priority ?? .normal
            let priority2 = taskRegistry[config2.identifier]?.priority ?? .normal
            return priority1 < priority2
        }
        
        for (index, config) in sorted.enumerated() {
            if index == 0 {
                shifted.append(config)
            } else {
                let offset = TimeInterval(index * minutes * 60)
                let newDate = config.triggerDate.addingTimeInterval(offset)
                let shiftedConfig = TaskNotificationConfig(
                    identifier: config.identifier,
                    title: config.title,
                    body: config.body,
                    triggerDate: newDate,
                    sound: config.sound,
                    badge: config.badge,
                    userInfo: config.userInfo
                )
                shifted.append(shiftedConfig)
            }
        }
        
        return shifted
    }
    
    private func handleConflictNotification(_ group: [TaskNotificationConfig]) {
        // 发送冲突通知
        let content = UNMutableNotificationContent()
        content.title = "通知冲突"
        content.body = "检测到 \(group.count) 个通知时间冲突"
        content.sound = .default
        content.userInfo = ["conflict": true, "count": group.count]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "conflict_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    // MARK: - 窗口管理
    private func removeNotificationsOutsideWindow(_ windowConfigs: [TaskNotificationConfig], for taskIdentifier: String) {
        let windowIds = Set(windowConfigs.map { self.generateNotificationId(for: $0, taskIdentifier: taskIdentifier) })
        
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            
            let idsToRemove = requests
                .filter { request in
                    // 只移除属于当前任务的、且不在窗口内的通知
                    request.identifier.hasPrefix(taskIdentifier) && !windowIds.contains(request.identifier)
                }
                .map { $0.identifier }
            
            if !idsToRemove.isEmpty {
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
                print("🗑️ 移除窗口外通知: \(idsToRemove.count) 个")
            }
        }
    }
    
    private func createNotificationsInWindow(_ configs: [TaskNotificationConfig], for task: ScheduledTask, completion: @escaping (Result<Int, Error>) -> Void) {
        let group = DispatchGroup()
        var createdCount = 0
        var lastError: Error?
        
        for config in configs {
            group.enter()
            
            let content = config.toNotificationContent()
            let trigger = config.toNotificationTrigger()
            let identifier = generateNotificationId(for: config, taskIdentifier: task.taskIdentifier)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    lastError = error
                    print("⚠️ 创建通知失败: \(error.localizedDescription)")
                } else {
                    createdCount += 1
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = lastError, createdCount == 0 {
                completion(.failure(error))
            } else {
                completion(.success(createdCount))
            }
        }
    }
    
    private func generateNotificationId(for config: TaskNotificationConfig, taskIdentifier: String) -> String {
        return "\(taskIdentifier)_\(Int(config.triggerDate.timeIntervalSince1970))"
    }
    
    private func updateSchedulingTracker(_ configs: [TaskNotificationConfig], taskIdentifier: String) {
        // 更新通知ID追踪
        let newIds = Set(configs.map { generateNotificationId(for: $0, taskIdentifier: taskIdentifier) })
        
        // 移除旧的追踪
        scheduledNotificationIds = scheduledNotificationIds.filter { !$0.hasPrefix(taskIdentifier) }
        
        // 添加新的追踪
        scheduledNotificationIds.formUnion(newIds)
        
        // 更新映射
        for config in configs {
            let notificationId = generateNotificationId(for: config, taskIdentifier: taskIdentifier)
            notificationTaskMap[notificationId] = taskIdentifier
        }
    }
    
    // MARK: - 动态补位
    func performRollingWindowMaintenance() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 检查维护间隔
            guard Date().timeIntervalSince(self.lastMaintenanceTime) > self.maintenanceInterval else {
                return
            }
            
            self.lastMaintenanceTime = Date()
            print("🔧 开始滚动窗口维护")
            
            self.notificationCenter.getPendingNotificationRequests { [weak self] requests in
                guard let self = self else { return }
                
                let currentCount = requests.count
                print("📊 当前系统通知数: \(currentCount)/\(self.maxSystemNotifications)")
                
                // 检查是否需要补位
                if currentCount < self.minWindowThreshold {
                    print("🔄 通知数低于阈值，触发补位")
                    self.refillRollingWindow()
                }
                
                // 按优先级维护任务
                let sortedTasks = self.taskRegistry.values.sorted { $0.priority < $1.priority }
                
                for task in sortedTasks {
                    let taskNotificationCount = requests.filter { $0.identifier.hasPrefix(task.taskIdentifier) }.count
                    
                    // 如果某个任务的通知数不足，重新调度
                    if taskNotificationCount < self.minWindowThreshold / max(1, self.taskRegistry.count) {
                        print("📋 任务 '\(task.taskIdentifier)' 通知不足 (\(taskNotificationCount))，重新调度")
                        self.performRollingWindowScheduling(for: task) { _ in }
                    }
                }
            }
        }
    }
    
    private func refillRollingWindow() {
        // 收集所有任务的配置
        var allConfigs: [TaskNotificationConfig] = []
        
        for task in taskRegistry.values {
            allConfigs.append(contentsOf: task.getNotificationConfigs())
        }
        
        // 过滤未来通知
        let now = Date()
        let futureConfigs = allConfigs
            .filter { $0.triggerDate > now }
            .sorted { $0.triggerDate < $1.triggerDate }
        
        // 解决冲突
        let resolvedConfigs = self.resolveTimeConflicts(futureConfigs)
        
        // 应用滚动窗口
        let windowedConfigs = Array(resolvedConfigs.prefix(rollingWindowSize))
        
        // 创建通知
        let group = DispatchGroup()
        for config in windowedConfigs {
            group.enter()
            let content = config.toNotificationContent()
            let trigger = config.toNotificationTrigger()
            let identifier = generateNotificationId(for: config, taskIdentifier: config.identifier)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            notificationCenter.add(request) { _ in
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("✅ 补位完成: 创建了 \(windowedConfigs.count) 个通知")
        }
    }
    
    private func ensureCriticalTasksCoverage() {
        for task in taskRegistry.values where task.priority == .critical {
            performRollingWindowScheduling(for: task) { _ in }
        }
    }
    
    // MARK: - 任务管理
    func updateTask(_ task: ScheduledTask, completion: @escaping (Result<Int, Error>) -> Void) {
        registerTask(task, completion: completion)
    }
    
    func removeTask(_ identifier: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.taskRegistry.removeValue(forKey: identifier)
            
            // 移除相关通知
            self.notificationCenter.getPendingNotificationRequests { requests in
                let idsToRemove = requests
                    .filter { $0.identifier.hasPrefix(identifier) }
                    .map { $0.identifier }
                
                if !idsToRemove.isEmpty {
                    self.notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
                    print("🗑️ 移除任务 '\(identifier)' 的 \(idsToRemove.count) 个通知")
                }
            }
            
            // 清理追踪数据
            self.scheduledNotificationIds = self.scheduledNotificationIds.filter { !$0.hasPrefix(identifier) }
            self.notificationTaskMap = self.notificationTaskMap.filter { !$0.key.hasPrefix(identifier) }
        }
    }
    
    func removeAllTasks() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.taskRegistry.removeAll()
            self.scheduledNotificationIds.removeAll()
            self.notificationTaskMap.removeAll()
            self.notificationCenter.removeAllPendingNotificationRequests()
            print("🗑️ 已移除所有任务和通知")
        }
    }
    
    // MARK: - 查询方法
    func getAllTasks() -> [String: ScheduledTask] {
        return queue.sync { taskRegistry }
    }
    
    func getTask(identifier: String) -> ScheduledTask? {
        return queue.sync { taskRegistry[identifier] }
    }
    
    func getPendingCount(for identifier: String) -> Int {
        var count = 0
        let semaphore = DispatchSemaphore(value: 0)
        notificationCenter.getPendingNotificationRequests { requests in
            count = requests.filter { $0.identifier.hasPrefix(identifier) }.count
            semaphore.signal()
        }
        semaphore.wait()
        return count
    }
    
    // MARK: - 冲突策略配置
    func setConflictStrategy(_ strategy: TimeConflictStrategy) {
        queue.async { [weak self] in
            self?.conflictStrategy = strategy
            print("⚙️ 冲突策略已更新: \(strategy)")
        }
    }
    
    func setTimeGranularity(_ granularity: TimeInterval) {
        queue.async { [weak self] in
            self?.timeGranularity = granularity
        }
    }
    
    // MARK: - 状态保存与恢复
    private func saveState() {
        let state: [String: Any] = [
            "taskIdentifiers": Array(taskRegistry.keys),
            "conflictStrategy": String(describing: conflictStrategy),
            "timeGranularity": timeGranularity,
            "lastMaintenanceTime": lastMaintenanceTime.timeIntervalSince1970
        ]
        
        UserDefaults.standard.set(state, forKey: "TaskNotificationManagerState")
    }
    
    private func restoreState() {
        guard let state = UserDefaults.standard.dictionary(forKey: "TaskNotificationManagerState") else {
            return
        }
        
        if let granularity = state["timeGranularity"] as? TimeInterval {
            timeGranularity = granularity
        }
        
        if let lastMaintenance = state["lastMaintenanceTime"] as? TimeInterval {
            lastMaintenanceTime = Date(timeIntervalSince1970: lastMaintenance)
        }
    }
    
    // MARK: - 调试信息
    func printDebugInfo() {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            
            print("""
            
            ═══════════════════════════════════════
            通知管理器状态 (滚动窗口模式)
            ═══════════════════════════════════════
            系统通知总数: \(requests.count)/\(self.maxSystemNotifications)
            窗口大小: \(self.rollingWindowSize)
            最小阈值: \(self.minWindowThreshold)
            冲突策略: \(self.conflictStrategy)
            时间粒度: \(self.timeGranularity)秒
            
            已注册任务: \(self.taskRegistry.count)
            追踪通知数: \(self.scheduledNotificationIds.count)
            
            任务详情:
            """)
            
            for (id, task) in self.taskRegistry {
                let configs = task.getNotificationConfigs()
                let pendingCount = requests.filter { $0.identifier.hasPrefix(id) }.count
                let nextTriggerDate = configs.first?.triggerDate
                let nextTriggerDateString = nextTriggerDate?.stringWithFormat("yyyy-MM-dd HH:mm:ss EEEE",
                                                                              timeZone: TimeZone.current,
                                                                              locale: Locale(identifier: "zh_CN"))
                print("""
                  📋 任务: \(id)
                     优先级: \(task.priority)
                     总配置数: \(configs.count)
                     待处理通知: \(pendingCount)
                     下次触发: \(nextTriggerDateString ?? "无")
                """)
            }
            
            print("═══════════════════════════════════════\n")
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
        let userInfo = response.notification.request.content.userInfo
        
        handleNotificationAction(response.actionIdentifier, userInfo: userInfo)
        
        if let badge = response.notification.request.content.badge {
            UIApplication.shared.applicationIconBadgeNumber = max(0, UIApplication.shared.applicationIconBadgeNumber - badge.intValue)
        }
        
        completionHandler()
    }
    
    private func handleNotificationAction(_ actionIdentifier: String, userInfo: [AnyHashable: Any]) {
        guard let taskIdentifier = userInfo["taskIdentifier"] as? String else { return }
        
        switch actionIdentifier {
        case "COMPLETE_ACTION":
            handleTaskCompleted(taskIdentifier)
        case "SNOOZE_ACTION":
            handleTaskSnoozed(taskIdentifier)
        case UNNotificationDefaultActionIdentifier:
            handleTaskTapped(taskIdentifier)
        default:
            break
        }
    }
    
    private func handleTaskCompleted(_ identifier: String) {
        // 发布完成通知
        NotificationCenter.default.post(
            name: Notification.Name("TaskCompleted"),
            object: nil,
            userInfo: ["taskIdentifier": identifier]
        )
        
        // 触发补位
        if let task = taskRegistry[identifier] {
            performRollingWindowScheduling(for: task) { _ in }
        }
    }
    
    private func handleTaskSnoozed(_ identifier: String) {
        // 创建延迟通知
        if let task = taskRegistry[identifier] {
            let configs = task.getNotificationConfigs()
            if let firstConfig = configs.first {
                let snoozedDate = Date().addingTimeInterval(10 * 60) // 10分钟后
                let snoozedConfig = TaskNotificationConfig(
                    identifier: "\(identifier)_snoozed",
                    title: "⏰ " + firstConfig.title,
                    body: firstConfig.body,
                    triggerDate: snoozedDate,
                    sound: firstConfig.sound
                )
                
                let content = snoozedConfig.toNotificationContent()
                let trigger = snoozedConfig.toNotificationTrigger()
                let request = UNNotificationRequest(
                    identifier: "\(identifier)_snoozed_\(Int(snoozedDate.timeIntervalSince1970))",
                    content: content,
                    trigger: trigger
                )
                
                notificationCenter.add(request)
            }
        }
    }
    
    private func handleTaskTapped(_ identifier: String) {
        NotificationCenter.default.post(
            name: Notification.Name("TaskNotificationTapped"),
            object: nil,
            userInfo: ["taskIdentifier": identifier]
        )
    }
}

// MARK: - 使用示例
// 1. 每日任务示例
class DailyTask: ScheduledTask {
    let taskIdentifier = "daily_task"
    var priority: TaskPriority { .normal }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        var configs: [TaskNotificationConfig] = []
        let calendar = Calendar.current
        let now = Date()
        
        // 生成未来7天的通知配置
        for dayOffset in 0..<7 {
            guard let triggerDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            
            var components = calendar.dateComponents([.year, .month, .day], from: triggerDate)
            components.hour = 9
            components.minute = 0
            
            if let scheduledDate = calendar.date(from: components), scheduledDate > now {
                let config = TaskNotificationConfig(
                    identifier: taskIdentifier,
                    title: "📝 每日任务",
                    body: "完成今天的待办事项",
                    triggerDate: scheduledDate,
                    sound: .default,
                    badge: 1
                )
                configs.append(config)
            }
        }
        
        return configs
    }
}

// 2. 周会提醒示例
class WeeklyMeetingTask: ScheduledTask {
    let taskIdentifier = "weekly_meeting"
    var priority: TaskPriority { .high }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        var configs: [TaskNotificationConfig] = []
        let calendar = Calendar.current
        let now = Date()
        
        // 生成未来4周的周二和周四会议
        for weekOffset in 0..<4 {
            for weekday in [3, 5] { // 周二=3, 周四=5
                var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
                components.weekOfYear! += weekOffset
                components.weekday = weekday
                components.hour = 10
                components.minute = 0
                
                if let meetingDate = calendar.date(from: components), meetingDate > now {
                    let config = TaskNotificationConfig(
                        identifier: taskIdentifier,
                        title: "💼 周会提醒",
                        body: "15分钟后开始周会，请准备",
                        triggerDate: meetingDate,
                        sound: .default,
                        userInfo: ["meeting_type": "weekly", "room": "A101"]
                    )
                    configs.append(config)
                }
            }
        }
        
        return configs
    }
}

// 3. 自定义任务示例
class CustomTask: ScheduledTask {
    let taskIdentifier: String
    let priority: TaskPriority
    let notificationDates: [Date]
    let title: String
    let body: String
    
    init(identifier: String, title: String, body: String, dates: [Date], priority: TaskPriority = .normal) {
        self.taskIdentifier = identifier
        self.title = title
        self.body = body
        self.notificationDates = dates
        self.priority = priority
    }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        return notificationDates
            .filter { $0 > Date() }
            .map { date in
                TaskNotificationConfig(
                    identifier: taskIdentifier,
                    title: title,
                    body: body,
                    triggerDate: date,
                    sound: .default
                )
            }
    }
}

// MARK: - 测试代码
class NotificationTester {
    static func runTests() {
        print("🚀 开始测试滚动窗口通知管理器")
        
        let manager = TaskNotificationManager.shared
        
        // 测试1: 权限请求
        testAuthorization(manager)
        
        // 测试2: 注册任务
        testTaskRegistration(manager)
        
        // 测试3: 时间冲突处理
        testTimeConflict(manager)
        
        // 测试4: 滚动窗口
        testRollingWindow(manager)
        
        // 测试5: 动态补位
        testDynamicRefill(manager)
        
        // 测试6: 调试信息
        testDebugInfo(manager)
    }
    
    static func testAuthorization(_ manager: TaskNotificationManager) {
        print("\n📋 测试1: 权限管理")
        manager.requestAuthorization { granted in
            print("通知权限: \(granted ? "已授权" : "未授权")")
        }
    }
    
    static func testTaskRegistration(_ manager: TaskNotificationManager) {
        print("\n📋 测试2: 任务注册")
        
        let dailyTask = DailyTask()
        manager.registerTask(dailyTask) { result in
            switch result {
            case .success(let count):
                print("✅ 每日任务注册成功，创建 \(count) 个通知")
            case .failure(let error):
                print("❌ 注册失败: \(error.localizedDescription)")
            }
        }
        
        let meetingTask = WeeklyMeetingTask()
        manager.registerTask(meetingTask) { result in
            switch result {
            case .success(let count):
                print("✅ 会议任务注册成功，创建 \(count) 个通知")
            case .failure(let error):
                print("❌ 注册失败: \(error.localizedDescription)")
            }
        }
    }
    
    static func testTimeConflict(_ manager: TaskNotificationManager) {
        print("\n📋 测试3: 时间冲突处理")
        
        let now = Date()
        let conflictDate = Calendar.current.date(byAdding: .minute, value: 5, to: now)!
        
        // 创建两个时间接近的任务
        let task1 = CustomTask(
            identifier: "conflict_test_1",
            title: "任务1",
            body: "测试冲突1",
            dates: [conflictDate],
            priority: .normal
        )
        
        let task2 = CustomTask(
            identifier: "conflict_test_2",
            title: "任务2",
            body: "测试冲突2",
            dates: [conflictDate.addingTimeInterval(30)], // 30秒后
            priority: .high
        )
        
        manager.setConflictStrategy(.shift(minutes: 5))
        
        manager.registerTask(task1) { _ in
            manager.registerTask(task2) { _ in
                print("冲突测试任务已注册")
            }
        }
    }
    
    static func testRollingWindow(_ manager: TaskNotificationManager) {
        print("\n📋 测试4: 滚动窗口")
        
        // 创建多个通知以测试窗口限制
        var dates: [Date] = []
        let now = Date()
        for i in 0..<30 {
            if let date = Calendar.current.date(byAdding: .hour, value: i, to: now) {
                dates.append(date)
            }
        }
        
        let largeTask = CustomTask(
            identifier: "large_task",
            title: "大量通知测试",
            body: "测试滚动窗口",
            dates: dates
        )
        
        manager.registerTask(largeTask) { result in
            switch result {
            case .success(let count):
                print("✅ 大量通知任务: 生成\(dates.count)个配置，实际创建\(count)个（窗口限制）")
            case .failure(let error):
                print("❌ 失败: \(error.localizedDescription)")
            }
        }
    }
    
    static func testDynamicRefill(_ manager: TaskNotificationManager) {
        print("\n📋 测试5: 动态补位")
        
        // 模拟进入后台再回来
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            manager.performRollingWindowMaintenance()
        }
    }
    
    static func testDebugInfo(_ manager: TaskNotificationManager) {
        print("\n📋 测试6: 调试信息")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            manager.printDebugInfo()
        }
    }
}

// MARK: - ViewController 集成示例
class NotificationDemoViewController: UIViewController {
    
    private let manager = TaskNotificationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        observeTaskActions()
    }
    
    private func setupNotifications() {
        manager.requestAuthorization { [weak self] granted in
            guard granted else {
                self?.showPermissionAlert()
                return
            }
            
            // 注册任务
            self?.registerDefaultTasks()
        }
    }
    
    private func registerDefaultTasks() {
        let tasks: [ScheduledTask] = [
            DailyTask(),
            WeeklyMeetingTask()
        ]
        
        for task in tasks {
            manager.registerTask(task) { result in
                switch result {
                case .success(let count):
                    print("✅ \(task.taskIdentifier) 已注册，\(count)个通知")
                case .failure(let error):
                    print("❌ \(task.taskIdentifier) 注册失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func observeTaskActions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTaskCompleted(_:)),
            name: Notification.Name("TaskCompleted"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTaskTapped(_:)),
            name: Notification.Name("TaskNotificationTapped"),
            object: nil
        )
    }
    
    @objc private func handleTaskCompleted(_ notification: Notification) {
        guard let taskIdentifier = notification.userInfo?["taskIdentifier"] as? String else { return }
        print("✅ 任务完成: \(taskIdentifier)")
        
        // 这里可以更新任务状态
        // 滚动窗口会自动补位
    }
    
    @objc private func handleTaskTapped(_ notification: Notification) {
        guard let taskIdentifier = notification.userInfo?["taskIdentifier"] as? String else { return }
        print("📱 用户点击通知: \(taskIdentifier)")
        
        // 导航到相应页面
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "需要通知权限",
            message: "请在设置中开启通知权限以接收任务提醒",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - SwiftUI 集成示例
import SwiftUI

struct NotificationManagerView: View {
    @StateObject private var viewModel = NotificationViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section("权限") {
                    HStack {
                        Text("通知权限")
                        Spacer()
                        Text(viewModel.authorizationStatus)
                            .foregroundColor(viewModel.isAuthorized ? .green : .red)
                    }
                    
                    Button("请求权限") {
                        viewModel.requestPermission()
                    }
                }
                
                Section("任务管理") {
                    Button("添加每日任务") {
                        viewModel.addDailyTask()
                    }
                    
                    Button("添加周会任务") {
                        viewModel.addWeeklyMeetingTask()
                    }
                }
                
                Section("滚动窗口控制") {
                    HStack {
                        Text("窗口大小")
                        Spacer()
                        Text("20")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("补位阈值")
                        Spacer()
                        Text("8")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("手动补位") {
                        viewModel.manualRefill()
                    }
                }
                
                Section("冲突策略") {
                    Picker("策略", selection: $viewModel.selectedStrategy) {
                        Text("偏移5分钟").tag(0)
                        Text("保留优先").tag(1)
                        Text("保留最早").tag(2)
                    }
                    .onChange(of: viewModel.selectedStrategy) { newValue in
                        viewModel.updateConflictStrategy(newValue)
                    }
                }
                
                Section("调试") {
                    Button("打印状态") {
                        viewModel.printDebugInfo()
                    }
                    
                    Button("清除所有", role: .destructive) {
                        viewModel.clearAll()
                    }
                }
            }
            .navigationTitle("通知管理器")
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}

class NotificationViewModel: ObservableObject {
    @Published var authorizationStatus = "未知"
    @Published var isAuthorized = false
    @Published var selectedStrategy = 0
    
    private let manager = TaskNotificationManager.shared
    
    func onAppear() {
        checkAuthorization()
    }
    
    func requestPermission() {
        manager.requestAuthorization { [weak self] granted in
            self?.checkAuthorization()
        }
    }
    
    func checkAuthorization() {
        let status = manager.checkAuthorizationStatus()
        DispatchQueue.main.async {
            switch status {
            case .authorized, .provisional:
                self.authorizationStatus = "已授权"
                self.isAuthorized = true
            case .denied:
                self.authorizationStatus = "已拒绝"
                self.isAuthorized = false
            default:
                self.authorizationStatus = "未确定"
                self.isAuthorized = false
            }
        }
    }
    
    func addDailyTask() {
        let task = DailyTask()
        manager.registerTask(task) { _ in }
    }
    
    func addWeeklyMeetingTask() {
        let task = WeeklyMeetingTask()
        manager.registerTask(task) { _ in }
    }
    
    func manualRefill() {
        manager.performRollingWindowMaintenance()
    }
    
    func updateConflictStrategy(_ strategy: Int) {
        switch strategy {
        case 0:
            manager.setConflictStrategy(.shift(minutes: 5))
        case 1:
            manager.setConflictStrategy(.keepHighestPriority)
        case 2:
            manager.setConflictStrategy(.keepEarliest)
        default:
            break
        }
    }
    
    func printDebugInfo() {
        manager.printDebugInfo()
    }
    
    func clearAll() {
        manager.removeAllTasks()
    }
}

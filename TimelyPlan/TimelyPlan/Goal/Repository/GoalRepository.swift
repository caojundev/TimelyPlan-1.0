//
//  GoalRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

struct GoalUpdaterOption: OptionSet {
    
    let rawValue: Int
    
    static let plan = GoalUpdaterOption(rawValue: 1 << 1)
    
    static let task = GoalUpdaterOption(rawValue: 2 << 1)
    
    static let record = GoalUpdaterOption(rawValue: 3 << 1)
    
    /// 所有
    static let all: GoalUpdaterOption = [.plan, .task, .record]
}


class GoalRepository {
    
    // MARK: - 数据管理器
    private static let planManager = GoalPlanManager()
    
    /// 目标任务管理器
    private static let taskManager: GoalTaskManager = {
        let manager = GoalTaskManager()
        manager.planUpdater = planManager.updater
        return manager
    }()
    
    /// 目标记录管理器
    private static let recordManager: GoalRecordManager = {
        let manager = GoalRecordManager(taskManager: taskManager)
        manager.planUpdater = planManager.updater
        return manager
    }()
    
    // MARK: - 注册远程数据变更
    private static var isRemoteChangeObserved = false
    private static func observeRemoteChangeIfNeeded() {
        if isRemoteChangeObserved {
            return
        }
        
        isRemoteChangeObserved = true
        HandyRecord.observeRemoteChange { changeInfo in
            let entityNames = changeInfo.entityNames
            if entityNames.contains(.goalPlan) {
                let results = changeInfo.extractGoalPlan()
                planManager.updater.didChangeRemoteGoalPlan(with: results)
            }
            
            if entityNames.contains(.goalTask) {
                let results = changeInfo.extractGoalTask()
                taskManager.updater.didChangeRemoteGoalTask(with: results)
            }
            
            if entityNames.contains(.goalRecord) {
                let results = changeInfo.extractGoalRecord()
                recordManager.updater.didChangeRemoteGoalRecord(with: results)
            }
        }
    }
    
    /// 添加更新器代理对象
    static func addUpdater(_ updater: AnyObject, for option: GoalUpdaterOption = .all) {
        observeRemoteChangeIfNeeded()
    
        if option.contains(.plan) {
            planManager.updater.addDelegate(updater)
        }
        
        if option.contains(.task) {
            taskManager.updater.addDelegate(updater)
        }
        
        if option.contains(.record) {
            recordManager.updater.addDelegate(updater)
        }
    }
    
    /// 移除更新器代理对象
    static func removeUpdater(_ updater: AnyObject) {
        planManager.updater.removeDelegate(updater)
        taskManager.updater.removeDelegate(updater)
        recordManager.updater.removeDelegate(updater)
    }
    
    // MARK: - 获取
    /// 获取所有活动目标计划
    static func getActiveGoalPlans() -> [GoalPlan] {
        return planManager.getActiveGoalPlans() ?? []
    }
    
    /// 获取所有已归档目标计划
    static func getArchivedGoalPlans() -> [GoalPlan] {
        return planManager.getArchivedGoalPlans() ?? []
    }
    
    /// 异步获取所有活动目标计划
    static func fetchActiveGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        planManager.fetchActiveGoalPlans(completion: completion)
    }
    
    /// 异步获取所有已归档目标计划
    static func fetchArchivedGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        planManager.fetchArchivedGoalPlans(completion: completion)
    }
    
    /// 获取特定标识的目标计划
    static func getGoalPlan(withIdentifier identifier: String) -> GoalPlan? {
        return planManager.getGoalPlan(withIdentifier: identifier)
    }
    
    /// 获取已归档目标计划数目
    static func numberOfArchivedGoalPlans() -> Int {
        return planManager.numberOfArchivedGoalPlans()
    }
    
    /// 搜索活动目标计划
    static func searchActiveGoalPlans(containText text: String,
                                      completion: @escaping ([GoalPlan]?) -> Void) {
        planManager.searchActiveGoalPlans(containText: text, completion: completion)
    }
    
    // MARK: - 处理目标计划
    /// 创建目标计划
    static func createGoalPlan(with editingPlan: GoalEditingPlan) {
        planManager.createGoalPlan(with: editingPlan)
    }
    
    /// 更新目标计划
    static func updateGoalPlan(_ goalPlan: GoalPlan, with editingPlan: GoalEditingPlan) {
        planManager.updateGoalPlan(goalPlan, with: editingPlan)
    }
    
    /// 归档目标计划
    static func archiveGoalPlan(_ goalPlan: GoalPlan) {
        planManager.setArchived(true, for: goalPlan)
    }
    
    /// 取消归档目标计划
    static func unarchiveGoalPlan(_ goalPlan: GoalPlan) {
        planManager.setArchived(false, for: goalPlan)
    }
    
    /// 删除目标计划
    static func deleteGoalPlan(_ goalPlan: GoalPlan) {
        planManager.deleteGoalPlan(goalPlan)
    }
    
    /// 重排目标计划
    static func reorderGoalPlan(in goalPlans: [GoalPlan], fromIndex: Int, toIndex: Int) {
        planManager.reorderGoalPlan(in: goalPlans, fromIndex: fromIndex, toIndex: toIndex)
    }
}

// MARK: - 目标任务
extension GoalRepository {
    
    // MARK: - 获取目标任务
    /// 获取特定标识的目标任务
    static func getGoalTask(withIdentifier identifier: String) -> GoalTask? {
        return taskManager.getGoalTask(withIdentifier: identifier)
    }
    
    
    /// 异步获取所有未完成目标任务
    static func fetchGoalTasks(of goalPlan: GoalPlan,
                               completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchGoalTasks(of: goalPlan, completion: completion)
    }
    
    /// 异步获取所有收件箱目标任务（未归属任何目标计划）
    static func fetchInboxGoalTasks(completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchInboxGoalTasks(completion: completion)
    }
    
    /// 获取特定日期区间内的目标任务
    static func fetchCalendarEventGoalTasks(in range: DateInterval,
                                            completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchCalendarEventGoalTasks(in: range, completion: completion)
    }
    
    /// 获取我的一天中特定日期区间内的目标任务
    static func fetchMyDayEventGoalTasks(in range: DateInterval,
                                         completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchMyDayEventGoalTasks(in: range, completion: completion)
    }
    
    /// 获取甘特图目标任务
    static func fetchGanttEventGoalTasks(in range: DateInterval,
                                         showCompleted: Bool = true,
                                         completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchGanttEventGoalTasks(in: range,
                                             showCompleted: showCompleted,
                                             completion: completion)
    }
    
    /// 获取包含提醒的目标任务
    static func fetchNotifiableGoalTasks(completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchNotifiableGoalTasks(completion: completion)
    }
    
    /// 搜索目标任务
    static func searchGoalTasks(containText text: String,
                                showCompleted: Bool = true,
                                completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.searchGoalTasks(containText: text,
                                    showCompleted: showCompleted,
                                    completion: completion)
    }
    
    // MARK: - 处理目标任务
    /// 创建目标任务（按 editingTask.goalPlan 归属目标计划，收件箱表示不属于任何目标计划）
    @discardableResult
    static func createGoalTask(with editingTask: GoalEditingTask) -> GoalTask? {
        return taskManager.createGoalTask(with: editingTask)
    }
    
    /// 使用编辑模型整体更新目标任务
    @discardableResult
    static func updateGoalTask(_ goalTask: GoalTask,
                               with editingTask: GoalEditingTask) -> GoalTask? {
        return taskManager.updateGoalTask(goalTask, with: editingTask)
    }
    
    static func updateGoalTask(_ goalTask: GoalTask, name: String?) {
        taskManager.updateGoalTask(goalTask, name: name)
    }
    
    static func updateGoalTask(_ goalTask: GoalTask, note: String?) {
        taskManager.updateGoalTask(goalTask, note: note)
    }
    
    static func updateGoalTask(_ goalTask: GoalTask, steps: [TodoStep]?) {
        taskManager.updateGoalTask(goalTask, steps: steps)
    }
    
    /// 记录当前数值
    static func updateGoalTask(_ goalTask: GoalTask, currentValue: Int64) {
        taskManager.updateGoalTask(goalTask, currentValue: currentValue)
    }
    
    /// 自动记录一次进度
    static func autoRecordProgress(for goalTask: GoalTask) {
        taskManager.autoRecordProgress(for: goalTask)
    }
    
    /// 更新完成状态
    static func updateGoalTask(_ goalTask: GoalTask, isCompleted: Bool) {
        taskManager.updateGoalTask(goalTask, isCompleted: isCompleted)
    }
    
    static func updateGoalTasks(_ goalTasks: [GoalTask], isCompleted: Bool) {
        taskManager.updateGoalTasks(goalTasks, isCompleted: isCompleted)
    }
    
    /// 更新我的一天
    static func updateGoalTask(_ goalTask: GoalTask, isAddedToMyDay: Bool) {
        taskManager.updateGoalTask(goalTask, isAddedToMyDay: isAddedToMyDay)
    }
    
    static func updateGoalTasks(_ goalTasks: [GoalTask], isAddedToMyDay: Bool) {
        taskManager.updateGoalTasks(goalTasks, isAddedToMyDay: isAddedToMyDay)
    }
    
    /// 删除目标任务
    static func deleteGoalTask(_ goalTask: GoalTask) {
        taskManager.deleteGoalTask(goalTask)
    }
    
    static func deleteGoalTasks(_ goalTasks: [GoalTask]) {
        taskManager.deleteGoalTasks(goalTasks)
    }
    
    // MARK: - 排序任务
    static func reorderGoalTask(_ sourceTask: GoalTask,
                                postion: TodoTaskInsertPosition,
                                targetTask: GoalTask,
                                in goalPlan: GoalPlan) {
        taskManager.reorderGoalTask(sourceTask, postion: postion, targetTask: targetTask, in: goalPlan)
    }
    
    // MARK: - 移动任务
    /// 将目标任务移动到新的目标计划
    static func moveGoalTask(_ goalTask: GoalTask, to goalPlan: GoalPlan) {
        taskManager.moveGoalTask(goalTask, to: goalPlan)
    }
    
}

// MARK: - 目标记录
extension GoalRepository {
    
    /// 添加一条记录（仅记录，不会更新目标任务的当前数值）
    @discardableResult
    static func addRecord(amount: Int64,
                          note: String? = nil,
                          for goalTask: GoalTask,
                          on date: Date = .now) -> GoalRecord? {
        return recordManager.addRecord(amount: amount,
                                       note: note,
                                       for: goalTask,
                                       on: date)
    }
    
    /// 记录进度：更新目标任务当前数值并添加一条记录
    static func record(amount: Int64,
                       inputType: GoalRecordInputType,
                       note: String? = nil,
                       for goalTask: GoalTask,
                       on date: Date = .now) {
        recordManager.record(amount: amount,
                             inputType: inputType,
                             note: note,
                             for: goalTask,
                             on: date)
    }
    
    /// 完成所有：把目标任务进度推进到目标值（100%）并记录本次变化量
    static func completeAll(for goalTask: GoalTask,
                            on date: Date = .now) {
        recordManager.completeAll(for: goalTask, on: date)
    }
    
    /// 重置指定日期的记录：删除目标任务在该日期的所有记录并回退任务当前值
    @discardableResult
    static func resetToday(of date: Date = .now,
                           for goalTask: GoalTask) -> Bool {
        return recordManager.resetToday(for: goalTask, on: date)
    }
    
    // MARK: - 获取
    /// 同步获取目标记录
    static func getRecords(for goalTask: GoalTask? = nil,
                           fromDate: Date? = nil,
                           toDate: Date? = nil) -> [GoalRecord] {
        return recordManager.getRecords(for: goalTask,
                                        fromDate: fromDate,
                                        toDate: toDate)
    }
    
    /// 异步获取目标记录
    static func fetchRecords(for goalTask: GoalTask? = nil,
                             fromDate: Date? = nil,
                             toDate: Date? = nil,
                             completion: @escaping ([GoalRecord]?) -> Void) {
        recordManager.fetchRecords(for: goalTask,
                                   fromDate: fromDate,
                                   toDate: toDate,
                                   completion: completion)
    }
    
    // MARK: - 删除
    /// 删除目标任务在指定日期区间内的记录（日期区间为 nil 表示不限制）
    @discardableResult
    static func deleteRecords(for goalTask: GoalTask? = nil,
                              fromDate: Date? = nil,
                              toDate: Date? = nil) -> Bool {
        return recordManager.deleteRecords(for: goalTask,
                                           fromDate: fromDate,
                                           toDate: toDate)
    }
    
    /// 删除单条目标记录
    @discardableResult
    static func deleteRecord(_ record: GoalRecord,
                             for goalTask: GoalTask) -> Bool {
        return recordManager.deleteRecord(record, for: goalTask)
    }
    
    /// 更新单条目标记录的数值与备注（数值变化后会按现有记录重算任务当前值）
    @discardableResult
    static func updateRecord(_ record: GoalRecord,
                             amount: Int64,
                             note: String?,
                             for goalTask: GoalTask) -> Bool {
        return recordManager.updateRecord(record,
                                          amount: amount,
                                          note: note,
                                          for: goalTask)
    }
}

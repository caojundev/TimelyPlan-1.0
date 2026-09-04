//
//  GoalRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

class GoalRepository {
    
    // MARK: - 数据管理器
    private static let manager = GoalPlanManager()
    
    /// 目标任务管理器
    private static let taskManager = GoalTaskManager()
    
    /// 添加更新器代理对象
    static func addUpdater(_ updater: AnyObject) {
        manager.updater.addDelegate(updater)
        taskManager.updater.addDelegate(updater)
    }
    
    /// 移除更新器代理对象
    static func removeUpdater(_ updater: AnyObject) {
        manager.updater.removeDelegate(updater)
        taskManager.updater.removeDelegate(updater)
    }
    
    // MARK: - 获取
    /// 获取所有活动目标计划
    static func getActiveGoalPlans() -> [GoalPlan] {
        return manager.getActiveGoalPlans() ?? []
    }
    
    /// 获取所有已归档目标计划
    static func getArchivedGoalPlans() -> [GoalPlan] {
        return manager.getArchivedGoalPlans() ?? []
    }
    
    /// 异步获取所有活动目标计划
    static func fetchActiveGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        manager.fetchActiveGoalPlans(completion: completion)
    }
    
    /// 异步获取所有已归档目标计划
    static func fetchArchivedGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        manager.fetchArchivedGoalPlans(completion: completion)
    }
    
    /// 获取特定标识的目标计划
    static func getGoalPlan(withIdentifier identifier: String) -> GoalPlan? {
        return manager.getGoalPlan(withIdentifier: identifier)
    }
    
    /// 获取已归档目标计划数目
    static func numberOfArchivedGoalPlans() -> Int {
        return manager.numberOfArchivedGoalPlans()
    }
    
    /// 搜索活动目标计划
    static func searchActiveGoalPlans(containText text: String,
                                      completion: @escaping ([GoalPlan]?) -> Void) {
        manager.searchActiveGoalPlans(containText: text, completion: completion)
    }
    
    // MARK: - 处理目标计划
    /// 创建目标计划
    static func createGoalPlan(with editingPlan: GoalEditingPlan) {
        manager.createGoalPlan(with: editingPlan)
    }
    
    /// 更新目标计划
    static func updateGoalPlan(_ goalPlan: GoalPlan, with editingPlan: GoalEditingPlan) {
        manager.updateGoalPlan(goalPlan, with: editingPlan)
    }
    
    /// 归档目标计划
    static func archiveGoalPlan(_ goalPlan: GoalPlan) {
        manager.setArchived(true, for: goalPlan)
    }
    
    /// 取消归档目标计划
    static func unarchiveGoalPlan(_ goalPlan: GoalPlan) {
        manager.setArchived(false, for: goalPlan)
    }
    
    /// 删除目标计划
    static func deleteGoalPlan(_ goalPlan: GoalPlan) {
        manager.deleteGoalPlan(goalPlan)
    }
    
    /// 重排目标计划
    static func reorderGoalPlan(in goalPlans: [GoalPlan], fromIndex: Int, toIndex: Int) {
        manager.reorderGoalPlan(in: goalPlans, fromIndex: fromIndex, toIndex: toIndex)
    }
}

// MARK: - 目标任务
extension GoalRepository {
    
    // MARK: - 获取目标任务
    /// 同步获取所有目标任务
    static func getAllGoalTasks() -> [GoalTask]? {
        return taskManager.getAllGoalTasks()
    }
    
    /// 同步获取所有未完成目标任务
    static func getActiveGoalTasks() -> [GoalTask]? {
        return taskManager.getActiveGoalTasks()
    }
    
    /// 获取特定标识的目标任务
    static func getGoalTask(withIdentifier identifier: String) -> GoalTask? {
        return taskManager.getGoalTask(withIdentifier: identifier)
    }
    
    /// 未完成目标任务数目
    static func numberOfActiveGoalTasks() -> Int {
        return taskManager.numberOfActiveGoalTasks()
    }
    
    /// 异步获取所有目标任务
    static func fetchAllGoalTasks(showCompleted: Bool = true,
                                  completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchAllGoalTasks(showCompleted: showCompleted, completion: completion)
    }
    
    /// 异步获取所有未完成目标任务
    static func fetchActiveGoalTasks(completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchActiveGoalTasks(completion: completion)
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
    
    /// 获取包含提醒的目标任务
    static func fetchNotifiableGoalTasks(completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchNotifiableGoalTasks(completion: completion)
    }
    
    /// 获取特定区间内已完成的目标任务
    static func fetchCompletedGoalTasks(in range: DateRange,
                                        completion: @escaping ([GoalTask]?) -> Void) {
        taskManager.fetchCompletedGoalTasks(in: range, completion: completion)
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
    /// 创建目标任务
    @discardableResult
    static func createGoalTask(with editingTask: GoalEditingTask) -> GoalTask {
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
    
    /// 重排目标任务
    static func reorderGoalTask(in goalTasks: [GoalTask], fromIndex: Int, toIndex: Int) {
        taskManager.reorderGoalTask(in: goalTasks, fromIndex: fromIndex, toIndex: toIndex)
    }
}

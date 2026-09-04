//
//  GoalTaskManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/4.
//

import Foundation
import CoreData

class GoalTaskManager {
    
    /// 目标任务处理更新器
    let updater = GoalTaskProcessorUpdater()
    
    /// 默认上下文对象
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    // MARK: - 获取目标任务
    /// 同步获取所有目标任务
    func getAllGoalTasks() -> [GoalTask]? {
        return CDGoalTask.getAllGoalTasks()?.toGoalTasks
    }
    
    /// 同步获取所有未完成目标任务
    func getActiveGoalTasks() -> [GoalTask]? {
        return CDGoalTask.getActiveGoalTasks()?.toGoalTasks
    }
    
    /// 获取特定标识的目标任务
    func getGoalTask(withIdentifier identifier: String) -> GoalTask? {
        guard let content = CDGoalTask.getGoalTask(withIdentifier: identifier) else {
            return nil
        }
        
        return GoalTask(content: content)
    }
    
    /// 未完成目标任务数目
    func numberOfActiveGoalTasks() -> Int {
        return CDGoalTask.numberOfActiveGoalTasks()
    }
    
    // MARK: - 异步获取目标任务
    func fetchAllGoalTasks(showCompleted: Bool = true,
                           completion: @escaping ([GoalTask]?) -> Void) {
        CDGoalTask.fetchAllGoalTasks(showCompleted: showCompleted) { results in
            completion(results?.toGoalTasks)
        }
    }
    
    func fetchActiveGoalTasks(completion: @escaping ([GoalTask]?) -> Void) {
        CDGoalTask.fetchActiveGoalTasks { results in
            completion(results?.toGoalTasks)
        }
    }
    
    func fetchCalendarEventGoalTasks(in range: DateInterval,
                                     completion: @escaping ([GoalTask]?) -> Void) {
        CDGoalTask.fetchCalendarEventGoalTasks(in: range) { results in
            completion(results?.toGoalTasks)
        }
    }
    
    func fetchMyDayEventGoalTasks(in range: DateInterval,
                                  completion: @escaping ([GoalTask]?) -> Void) {
        CDGoalTask.fetchMyDayEventGoalTasks(in: range) { results in
            completion(results?.toGoalTasks)
        }
    }
    
    func fetchNotifiableGoalTasks(completion: @escaping ([GoalTask]?) -> Void) {
        CDGoalTask.fetchNotifiableGoalTasks { results in
            completion(results?.toGoalTasks)
        }
    }
    
    /// 获取特定区间内已完成的目标任务
    func fetchCompletedGoalTasks(in range: DateRange,
                                 completion: @escaping ([GoalTask]?) -> Void) {
        guard let start = range.startDate, let end = range.endDate else {
            completion(nil)
            return
        }
        
        let dateInterval = DateInterval(start: start, end: end)
        CDGoalTask.fetchCompletedGoalTasks(in: dateInterval) { results in
            completion(results?.toGoalTasks)
        }
    }
    
    /// 搜索目标任务
    func searchGoalTasks(containText text: String,
                         showCompleted: Bool = true,
                         completion: @escaping ([GoalTask]?) -> Void) {
        CDGoalTask.searchGoalTasks(containText: text,
                                   showCompleted: showCompleted) { results in
            completion(results?.toGoalTasks)
        }
    }
    
    // MARK: - 创建目标任务
    /// 创建目标任务
    @discardableResult
    func createGoalTask(with editingTask: GoalEditingTask) -> GoalTask {
        let content = CDGoalTask.newGoalTask(with: editingTask)
        content.order = CDGoalTask.maximumOrder + kOrderedStep
        
        let goalTask = GoalTask(content: content)
        updater.didCreateGoalTask(goalTask)
        HandyRecord.updateChangeCount()
        return goalTask
    }
    
    // MARK: - 更新目标任务
    /// 使用编辑模型整体更新目标任务
    @discardableResult
    func updateGoalTask(_ goalTask: GoalTask,
                        with editingTask: GoalEditingTask) -> GoalTask? {
        guard !goalTask.isSameTask(as: editingTask),
              let content = CDGoalTask.getGoalTask(withIdentifier: goalTask.identifier) else {
            return nil
        }
        
        let oldEditingTask = goalTask.editingTask
        content.update(with: editingTask)
        let updatedGoalTask = GoalTask(content: content)
        let change: GoalTaskChange = .content(oldValue: oldEditingTask, newValue: editingTask)
        updater.didUpdateGoalTask(updatedGoalTask, with: change)
        HandyRecord.updateChangeCount()
        return updatedGoalTask
    }
    
    func updateGoalTask(_ goalTask: GoalTask, name: String?) {
        guard goalTask.name != name, CDGoalTask.updateGoalTask(goalTask, name: name) else {
            return
        }
        
        let change: GoalTaskChange = .name(oldValue: goalTask.name, newValue: name)
        updater.didUpdateGoalTask(goalTask, with: change)
        HandyRecord.updateChangeCount()
    }
    
    func updateGoalTask(_ goalTask: GoalTask, note: String?) {
        guard goalTask.note != note, CDGoalTask.updateGoalTask(goalTask, note: note) else {
            return
        }
        
        let change: GoalTaskChange = .note(oldValue: goalTask.note, newValue: note)
        updater.didUpdateGoalTask(goalTask, with: change)
        HandyRecord.updateChangeCount()
    }
    
    func updateGoalTask(_ goalTask: GoalTask, steps: [TodoStep]?) {
        guard CDGoalTask.updateGoalTask(goalTask, steps: steps) else {
            return
        }
        
        let change: GoalTaskChange = .step(oldValue: goalTask.steps, newValue: steps)
        updater.didUpdateGoalTask(goalTask, with: change)
        HandyRecord.updateChangeCount()
    }
    
    // MARK: - 记录进度
    /// 更新当前数值，达到目标数值时自动标记为完成
    func updateGoalTask(_ goalTask: GoalTask, currentValue: Int64) {
        guard let validatedValue = CDGoalTask.updateGoalTask(goalTask,
                                                             currentValue: currentValue) else {
            return
        }
        
        let change: GoalTaskChange = .progress(oldValue: goalTask.currentValue,
                                               newValue: validatedValue)
        updater.didUpdateGoalTask(goalTask, with: change)
        
        /// 达成目标后自动完成
        if !goalTask.isCompleted,
           GoalTask.progressFraction(initialValue: goalTask.initialValue,
                                     targetValue: goalTask.targetValue,
                                     currentValue: validatedValue) >= 1.0 {
            updateGoalTasks([goalTask], isCompleted: true)
        }
        
        HandyRecord.updateChangeCount()
    }
    
    /// 自动记录一次进度
    func autoRecordProgress(for goalTask: GoalTask) {
        guard let currentValue = goalTask.autoRecordedCurrentValue() else {
            return
        }
        
        updateGoalTask(goalTask, currentValue: currentValue)
    }
    
    // MARK: - 完成状态
    func updateGoalTask(_ goalTask: GoalTask, isCompleted: Bool) {
        updateGoalTasks([goalTask], isCompleted: isCompleted)
    }
    
    func updateGoalTasks(_ goalTasks: [GoalTask], isCompleted: Bool) {
        var goalTasksToUpdate = [GoalTask]()
        for goalTask in goalTasks {
            if goalTask.isCompleted != isCompleted {
                goalTasksToUpdate.append(goalTask)
            }
        }
        
        guard goalTasksToUpdate.count > 0,
              CDGoalTask.updateGoalTasks(goalTasksToUpdate, isCompleted: isCompleted) else {
            return
        }
        
        if goalTasksToUpdate.count == 1 {
            let goalTask = goalTasksToUpdate[0]
            let change: GoalTaskChange = .completed(oldValue: goalTask.isCompleted,
                                                    newValue: isCompleted)
            updater.didUpdateGoalTask(goalTask, with: change)
        } else {
            var changeInfos = [GoalTaskChangeInfo]()
            for goalTask in goalTasksToUpdate {
                let change: GoalTaskChange = .completed(oldValue: goalTask.isCompleted,
                                                        newValue: isCompleted)
                changeInfos.append(GoalTaskChangeInfo(goalTask: goalTask, change: change))
            }
            
            updater.didUpdateGoalTasks(with: changeInfos)
        }
        
        HandyRecord.updateChangeCount()
    }
    
    // MARK: - 我的一天
    func updateGoalTask(_ goalTask: GoalTask, isAddedToMyDay: Bool) {
        updateGoalTasks([goalTask], isAddedToMyDay: isAddedToMyDay)
    }
    
    func updateGoalTasks(_ goalTasks: [GoalTask], isAddedToMyDay: Bool) {
        var goalTasksToUpdate = [GoalTask]()
        for goalTask in goalTasks {
            if goalTask.isAddedToMyDay != isAddedToMyDay {
                goalTasksToUpdate.append(goalTask)
            }
        }
        
        guard goalTasksToUpdate.count > 0,
              CDGoalTask.updateGoalTasks(goalTasksToUpdate, isAddedToMyDay: isAddedToMyDay) else {
            return
        }
        
        if goalTasksToUpdate.count == 1 {
            let goalTask = goalTasksToUpdate[0]
            let change: GoalTaskChange = .myDay(oldValue: goalTask.isAddedToMyDay,
                                                newValue: isAddedToMyDay)
            updater.didUpdateGoalTask(goalTask, with: change)
        } else {
            var changeInfos = [GoalTaskChangeInfo]()
            for goalTask in goalTasksToUpdate {
                let change: GoalTaskChange = .myDay(oldValue: goalTask.isAddedToMyDay,
                                                    newValue: isAddedToMyDay)
                changeInfos.append(GoalTaskChangeInfo(goalTask: goalTask, change: change))
            }
            
            updater.didUpdateGoalTasks(with: changeInfos)
        }
        
        HandyRecord.updateChangeCount()
    }
    
    // MARK: - 删除目标任务
    func deleteGoalTask(_ goalTask: GoalTask) {
        deleteGoalTasks([goalTask])
    }
    
    func deleteGoalTasks(_ goalTasks: [GoalTask]) {
        guard CDGoalTask.deleteGoalTasks(goalTasks) else {
            return
        }
        
        updater.didDeleteGoalTasks(goalTasks)
        HandyRecord.updateChangeCount()
    }
    
    // MARK: - 排序
    func reorderGoalTask(in goalTasks: [GoalTask], fromIndex: Int, toIndex: Int) {
        var goalTasks = goalTasks
        goalTasks.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        guard CDGoalTask.reorderGoalTask(in: goalTasks) else {
            return
        }
        
        updater.didReorderGoalTask(in: goalTasks, fromIndex: fromIndex, toIndex: toIndex)
        HandyRecord.updateChangeCount()
    }
}

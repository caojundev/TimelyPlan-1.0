//
//  GanttEventChangeObserver.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

class GanttEventChangeObserver {
    
    private let updater = GanttUpdater()
    
    let sources: [GanttEventSource]
    
    /// 是否通知所有的任务更新
    private let notifyAllUpdates: Bool = false
    
    init(sources: [GanttEventSource] = GanttEventSource.allCases) {
        self.sources = sources
        
        var observeSettingKeys: [GanttSetting.Key] = []
        
        /// 待办任务
        if sources.contains(.todo) {
            TodoRepository.addUpdater(self, for: [.task])
            observeSettingKeys.append(.showTodo)
        }
        
        /// 目标任务
        if sources.contains(.goal) {
            GoalRepository.addUpdater(self, for: [.task])
            observeSettingKeys.append(.showGoal)
        }
        
        if observeSettingKeys.count > 0 {
            GanttSetting.shared.addObserver(self, forKeys: observeSettingKeys)
        }
    }
    
    func addUpdaterDelegate(_ delegate: AnyObject) {
        updater.addDelegate(delegate)
    }
    
    func removeUpdaterDelegate(_ delegate: AnyObject) {
        updater.removeDelegate(delegate)
    }
}

extension GanttEventChangeObserver: SettingAgentObserver {
    
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = GanttSetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .showTodo, .showGoal:
            updater.ganttEventsDidChange(in: [.infiniteInterval])
        default:
            break
        }
    }
}

extension GanttEventChangeObserver: TodoTaskProcessorDelegate {
    
    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?) {
        updater.ganttEventsDidChange(in: [.infiniteInterval])
    }
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        guard let ranges = affectedRanges(for: [task]) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }

    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        let tasks = repeatTasks + updatedTasks
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }

    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        guard let ranges = ranges(for: task, with: change) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        var results = [DateInterval]()
        for changeInfo in changeInfos {
            if let ranges = ranges(for:changeInfo.task, with: changeInfo.change) {
                results.append(contentsOf: ranges)
            }
        }
        
        updater.ganttEventsDidChange(in: results)
    }
    
    private func affectedRanges(for tasks: [TodoTask]) -> [DateInterval]? {
        let hasRepeatTask = tasks.anySatisfy{ $0.isRecurringTask }
        if hasRepeatTask {
            return [.infiniteInterval]
        }
        
        var ranges = [DateInterval]()
        for task in tasks {
            if let range = task.schedule?.dateInfo?.dateInterval {
                ranges.append(range)
            }
        }
        
        if ranges.count == 0 {
            return nil
        }
        
        return ranges
    }
    
    private func ranges(for task: TodoTask, with change: TodoTaskChange) -> [DateInterval]? {
        if case let .schedule(oldValue, newValue) = change {
            /// 重复任务
            if let oldRepeatRule = oldValue?.repeatRule, oldRepeatRule.type != RepeatType.none {
                return [.infiniteInterval]
            }
            
            if let newRepeatRule = newValue?.repeatRule, newRepeatRule.type != RepeatType.none {
                return [.infiniteInterval]
            }
            
            /// 非重复任务
            var ranges = [DateInterval]()
            if let oldRange = oldValue?.dateInfo?.dateInterval {
                ranges.append(oldRange)
            }
            
            if let newRange = newValue?.dateInfo?.dateInterval {
                ranges.append(newRange)
            }
            
            return ranges
        }
        
        return affectedRanges(for: [task])
    }
}

extension GanttEventChangeObserver: GoalTaskProcessorDelegate {
    
    func didChangeRemoteGoalTask(with results: EntityChangeResults<GoalTask>?) {
        updater.ganttEventsDidChange(in: [.infiniteInterval])
    }
    
    func didCreateGoalTask(_ goalTask: GoalTask) {
        guard let ranges = affectedRanges(for: [goalTask]) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }
    
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        guard let ranges = ranges(for: goalTask, with: change) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }
    
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {
        var results = [DateInterval]()
        for changeInfo in changeInfos {
            if let ranges = ranges(for: changeInfo.goalTask, with: changeInfo.change) {
                results.append(contentsOf: ranges)
            }
        }
        
        updater.ganttEventsDidChange(in: results)
    }
    
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {
        guard let ranges = affectedRanges(for: goalTasks) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }
    
    func didReorderGoalTask(_ goalTask: GoalTask, in goalPlan: GoalPlan) {
        guard let ranges = affectedRanges(for: [goalTask]) else {
            return
        }
        
        updater.ganttEventsDidChange(in: ranges)
    }
    
    private func affectedRanges(for goalTasks: [GoalTask]) -> [DateInterval]? {
        var ranges = [DateInterval]()
        for goalTask in goalTasks {
            if let range = dateInterval(for: goalTask) {
                ranges.append(range)
            }
        }
        
        if ranges.count == 0 {
            return nil
        }
        
        return ranges
    }
    
    private func ranges(for goalTask: GoalTask, with change: GoalTaskChange) -> [DateInterval]? {
        if case let .content(oldValue, newValue) = change {
            var ranges = [DateInterval]()
            if let oldRange = dateInterval(startDate: oldValue.startDate, endDate: oldValue.endDate) {
                ranges.append(oldRange)
            }
            
            if let newRange = dateInterval(startDate: newValue.startDate, endDate: newValue.endDate) {
                ranges.append(newRange)
            }
            
            if ranges.count == 0 {
                return nil
            }
            
            return ranges
        }
        
        return affectedRanges(for: [goalTask])
    }
    
    private func dateInterval(for goalTask: GoalTask) -> DateInterval? {
        return dateInterval(startDate: goalTask.startDate, endDate: goalTask.endDate)
    }
    
    private func dateInterval(startDate: Date?, endDate: Date?) -> DateInterval? {
        guard let startDate = startDate else {
            return nil
        }
        
        let endDate = endDate ?? startDate
        guard endDate >= startDate else {
            return nil
        }
        
        return DateInterval(start: startDate, end: endDate)
    }
}


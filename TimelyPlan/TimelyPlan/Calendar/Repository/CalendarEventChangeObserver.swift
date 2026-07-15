//
//  CalendarEventChangeObserver.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/11.
//

import Foundation

class CalendarEventChangeObserver: SettingAgentObserver {
    
    private let updater = CalendarUpdater()
    
    let sources: [CalendarEventSource]
    
    init(sources: [CalendarEventSource] = CalendarEventSource.allCases) {
        self.sources = sources
        
        var observeSettingKeys: [CalendarSetting.Key] = []
        
        /// 系统事项
        if sources.contains(.system) {
            CalendarSystemManager.shared.addDelegate(self)
        }
        
        /// 待办任务
        if sources.contains(.todo) {
            TodoRepository.addUpdater(self, for: [.task])
            observeSettingKeys.append(.showCompletedTask)
        }
        
        /// 习惯任务
        if sources.contains(.habit) {
            HabitRepository.addUpdater(self, for: [.task])
            observeSettingKeys.append(contentsOf: [.showHabit, .habitDisplayRange])
        }
        
        if observeSettingKeys.count > 0 {
            CalendarSetting.shared.addObserver(self, forKeys: observeSettingKeys)
        }
    }
    
    func addUpdaterDelegate(_ delegate: AnyObject) {
        updater.addDelegate(delegate)
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = CalendarSetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .showCompletedTask, .showHabit, .habitDisplayRange:
            updater.calendarEventsDidChange(in: [.infiniteInterval])
        default:
            break
        }
    }
}

extension CalendarEventChangeObserver: CalendarSystemManagerDelegate {
    
    func calendarSystemManagerDidUpdate(_ manager: CalendarSystemManager) {
        updater.calendarEventsDidChange(in: [.infiniteInterval])
    }
}

extension CalendarEventChangeObserver: TodoTaskProcessorDelegate {
    
    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?) {
        updater.calendarEventsDidChange(in: [.infiniteInterval])
    }
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.calendarEventsDidChange(in: ranges)
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        guard let ranges = affectedRanges(for: [task]) else {
            return
        }
        
        updater.calendarEventsDidChange(in: ranges)
    }

    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        let tasks = repeatTasks + updatedTasks
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.calendarEventsDidChange(in: ranges)
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.calendarEventsDidChange(in: ranges)
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.calendarEventsDidChange(in: ranges)
    }

    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        guard let ranges = ranges(for: task, with: change) else {
            return
        }
        
        updater.calendarEventsDidChange(in: ranges)
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        var results = [DateInterval]()
        for changeInfo in changeInfos {
            if let ranges = ranges(for:changeInfo.task, with: changeInfo.change) {
                results.append(contentsOf: ranges)
            }
        }
        
        updater.calendarEventsDidChange(in: results)
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

extension CalendarEventChangeObserver: HabitTaskProcessorDelegate {
    
    /// 远程习惯任务改变
    func didChangeRemoteHabitTask(with results: EntityChangeResults<HabitTask>?) {
        updater.calendarEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 添加任务时通知
    func didCreateHabitTask(_ task: HabitTask) {
        let interval = task.dateRange.interval
        updater.calendarEventsDidChange(in: [interval])
    }
    
    /// 更新任务通知
    func didUpdateHabitTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        let oldInterval = task.dateRange.interval
        let newInterval = editingTask.dateRange.interval
        guard oldInterval != newInterval ||
                task.timePlan != editingTask.timePlan ||
                task.timeOption != editingTask.timeOption ||
                task.startTime != editingTask.startTime ||
                task.duration != editingTask.duration else {
            return
        }
        
        updater.calendarEventsDidChange(in: [oldInterval, newInterval])
    }
    
    /// 删除任务通知
    func didDeleteHabitTask(_ task: HabitTask) {
        let interval = task.dateRange.interval
        updater.calendarEventsDidChange(in: [interval])
    }
    
    /// 改变了任务的归档状态
    func didChangeArchivedState(for task: HabitTask) {
        let interval = task.dateRange.interval
        updater.calendarEventsDidChange(in: [interval])
    }
}

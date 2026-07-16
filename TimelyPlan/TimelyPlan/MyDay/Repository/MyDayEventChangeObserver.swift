//
//  MyDayEventChangeObserver.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

class MyDayEventChangeObserver {
    
    private let updater = MyDayUpdater()
    
    let sources: [MyDayEventSource]
    
    init(sources: [MyDayEventSource] = MyDayEventSource.allCases) {
        self.sources = sources
    
        /// 待办任务
        if sources.contains(.todo) {
            TodoRepository.addUpdater(self, for: [.task])
        }
        
        /// 习惯任务
        if sources.contains(.habit) {
            HabitRepository.addUpdater(self, for: [.task])
        }
        
        /// 专注计时器
        if sources.contains(.focus) {
            FocusRepository.addUpdater(self, for: [.timer])
        }
    }
    
    func addUpdaterDelegate(_ delegate: AnyObject) {
        updater.addDelegate(delegate)
    }
}

extension MyDayEventChangeObserver: TodoTaskProcessorDelegate {
    
    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?) {
        updater.myDayEventsDidChange(in: [.infiniteInterval])
    }
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.myDayEventsDidChange(in: ranges)
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        guard let ranges = affectedRanges(for: [task]) else {
            return
        }
        
        updater.myDayEventsDidChange(in: ranges)
    }

    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        let tasks = repeatTasks + updatedTasks
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.myDayEventsDidChange(in: ranges)
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.myDayEventsDidChange(in: ranges)
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        guard let ranges = affectedRanges(for: tasks) else {
            return
        }
        
        updater.myDayEventsDidChange(in: ranges)
    }

    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        guard let ranges = ranges(for: task, with: change) else {
            return
        }
        
        updater.myDayEventsDidChange(in: ranges)
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        var results = [DateInterval]()
        for changeInfo in changeInfos {
            if let ranges = ranges(for:changeInfo.task, with: changeInfo.change) {
                results.append(contentsOf: ranges)
            }
        }
        
        updater.myDayEventsDidChange(in: results)
    }
    
    private func affectedRanges(for tasks: [TodoTask]) -> [DateInterval]? {
        let myDayTasks = tasks.filter { $0.isAddedToMyDay }
        guard myDayTasks.count > 0 else {
            return nil
        }
        
        let hasRepeatTask = myDayTasks.anySatisfy{ $0.isRecurringTask }
        if hasRepeatTask {
            return [.infiniteInterval]
        }
        
        var ranges = [DateInterval]()
        for task in myDayTasks {
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
        if case .myDay(_, _) = change {
            if task.isRecurringTask {
                return [.infiniteInterval]
            }
            
            if let range = task.schedule?.dateInfo?.dateInterval {
                return [range]
            }
            
            return nil
        }

        guard task.isAddedToMyDay else {
            return nil
        }
        
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

extension MyDayEventChangeObserver: HabitTaskProcessorDelegate {
    
    /// 远程习惯任务改变
    func didChangeRemoteHabitTask(with results: EntityChangeResults<HabitTask>?) {
        updater.myDayEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 添加任务时通知
    func didCreateHabitTask(_ task: HabitTask) {
        guard task.isAddedToMyDay else {
            return
        }
        
        let interval = task.dateRange.interval
        updater.myDayEventsDidChange(in: [interval])
    }
    
    func didUpdateHabitTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        let oldInterval = task.dateRange.interval
        let newInterval = editingTask.dateRange.interval
        guard oldInterval != newInterval ||
                task.isAddedToMyDay != editingTask.isAddedToMyDay ||
                task.timePlan != editingTask.timePlan ||
                task.timeOption != editingTask.timeOption ||
                task.startTime != editingTask.startTime ||
                task.duration != editingTask.duration else {
            return
        }
        
        updater.myDayEventsDidChange(in: [oldInterval, newInterval])
    }
    
    /// 删除任务通知
    func didDeleteHabitTask(_ task: HabitTask) {
        guard task.isAddedToMyDay else {
            return
        }
        
        let interval = task.dateRange.interval
        updater.myDayEventsDidChange(in: [interval])
    }
    
    /// 改变了任务的归档状态
    func didChangeArchivedState(for task: HabitTask) {
        guard task.isAddedToMyDay else {
            return
        }
        
        let interval = task.dateRange.interval
        updater.myDayEventsDidChange(in: [interval])
    }
}

extension MyDayEventChangeObserver: FocusTimerProcessorDelegate {
    
    func didChangeRemoteFocusTimer(with results: EntityChangeResults<FocusTimer>?) {
        updater.myDayEventsDidChange(in: [.infiniteInterval])
    }
        
    func didCreateFocusTimer(_ timer: FocusTimer) {
        guard timer.isAddedToMyDay else {
            return
        }
        
        updater.myDayEventsDidChange(in: [timer.interval])
    }

    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {
        guard timer.isAddedToMyDay else {
            return
        }
        
        updater.myDayEventsDidChange(in: [timer.interval])
    }
    
    func didDeleteFocusTimer(_ timer: FocusTimer) {
        guard timer.isAddedToMyDay else {
            return
        }
        
        updater.myDayEventsDidChange(in: [timer.interval])
    }
    
    func didUpdateFocusTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {
        let oldInterval = timer.interval
        let newInterval = editingTimer.dateRange.interval
        guard oldInterval != newInterval ||
                timer.isAddedToMyDay != editingTimer.isAddedToMyDay ||
                timer.timePlan != editingTimer.timePlan ||
                timer.startTime != editingTimer.startTime else {
            return
        }
        
        updater.myDayEventsDidChange(in: [oldInterval, newInterval])
    }
    
}

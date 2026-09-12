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
    
    /// 是否通知所有的任务更新
    private let notifyAllUpdates: Bool = false
    
    init(sources: [MyDayEventSource] = MyDayEventSource.allCases) {
        self.sources = sources
        
        var observeSettingKeys: [MyDaySetting.Key] = []
        
        /// 系统事项
        if sources.contains(.calendar) {
            CalendarSystemManager.shared.addDelegate(self)
            observeSettingKeys.append(.showCalendarEvent)
        }
        
        /// 待办任务
        if sources.contains(.todo) {
            TodoRepository.addUpdater(self, for: [.task])
            observeSettingKeys.append(.showTodo)
        }
        
        /// 习惯任务
        if sources.contains(.habit) {
            HabitRepository.addUpdater(self, for: [.task])
            observeSettingKeys.append(.showHabit)
        }
        
        /// 目标任务
        if sources.contains(.goal) {
            GoalRepository.addUpdater(self, for: [.plan, .task])
            observeSettingKeys.append(.showGoal)
        }
        
        /// 专注计时器
        if sources.contains(.focus) {
            FocusRepository.addUpdater(self, for: [.timer])
            observeSettingKeys.append(.showFocus)
        }
        
        if observeSettingKeys.count > 0 {
            MyDaySetting.shared.addObserver(self, forKeys: observeSettingKeys)
        }
    }
    
    func addUpdaterDelegate(_ delegate: AnyObject) {
        updater.addDelegate(delegate)
    }
    
    func removeUpdaterDelegate(_ delegate: AnyObject) {
        updater.removeDelegate(delegate)
    }
}

extension MyDayEventChangeObserver: SettingAgentObserver {
    
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = MyDaySetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .showTodo, .showHabit, .showGoal, .showFocus, .showCalendarEvent:
            updater.myDayEventsDidChange(in: [.infiniteInterval])
        default:
            break
        }
    }
}

extension MyDayEventChangeObserver: CalendarSystemManagerDelegate {
    func calendarSystemManagerDidUpdate(_ manager: CalendarSystemManager) {
        updater.myDayEventsDidChange(in: [.infiniteInterval])
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
        let isMyDayChange: Bool
        if case .myDay(_, _) = change {
            isMyDayChange = true
        } else {
            isMyDayChange = false
        }
        
        guard isMyDayChange || task.isAddedToMyDay else {
            return
        }
        
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
        guard task.isAddedToMyDay || editingTask.isAddedToMyDay else {
            return
        }
        
        let oldInterval = task.dateRange.interval
        let newInterval = editingTask.dateRange.interval
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
        guard timer.isAddedToMyDay || editingTimer.isAddedToMyDay else {
            return
        }
        
        let oldInterval = timer.interval
        let newInterval = editingTimer.dateRange.interval
        updater.myDayEventsDidChange(in: [oldInterval, newInterval])
    }
    
}

extension MyDayEventChangeObserver: GoalPlanProcessorDelegate,
                                    GoalTaskProcessorDelegate {
    
    // MARK: - GoalPlanProcessorDelegate
    /// 远程目标计划改变
    func didChangeRemoteGoalPlan(with results: EntityChangeResults<GoalPlan>?) {
        updater.myDayEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 删除目标计划：计划下的目标任务会从“我的一天”移除
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {
        updater.myDayEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 归档目标计划：归档后其目标任务不再在“我的一天”展示
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {
        updater.myDayEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 取消归档目标计划：取消归档后其目标任务重新展示
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {
        updater.myDayEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 远程目标任务改变
    func didChangeRemoteGoalTask(with results: EntityChangeResults<GoalTask>?) {
        updater.myDayEventsDidChange(in: [.infiniteInterval])
    }
    
    /// 创建目标任务
    func didCreateGoalTask(_ goalTask: GoalTask) {
        guard goalTask.isAddedToMyDay else {
            return
        }
        
        updater.myDayEventsDidChange(in: [goalTask.dateRange.interval])
    }
    
    /// 更新单个目标任务
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        guard let ranges = ranges(for: goalTask, with: change) else {
            return
        }
        
        updater.myDayEventsDidChange(in: ranges)
    }
    
    /// 批量更新目标任务
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {
        var results = [DateInterval]()
        for changeInfo in changeInfos {
            if let ranges = ranges(for: changeInfo.goalTask, with: changeInfo.change) {
                results.append(contentsOf: ranges)
            }
        }
        
        updater.myDayEventsDidChange(in: results)
    }
    
    /// 目标任务彻底删除
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {
        guard let ranges = affectedRanges(for: goalTasks) else {
            return
        }
        
        updater.myDayEventsDidChange(in: ranges)
    }
    
    private func affectedRanges(for goalTasks: [GoalTask]) -> [DateInterval]? {
        let myDayTasks = goalTasks.filter { $0.isAddedToMyDay }
        guard myDayTasks.count > 0 else {
            return nil
        }
        
        return myDayTasks.map { $0.dateRange.interval }
    }
    
    private func ranges(for goalTask: GoalTask, with change: GoalTaskChange) -> [DateInterval]? {
        switch change {
        case .myDay(_, _), .completed(_, _):
            /// 我的一天归属或完成状态变化（包含移除），都需要刷新对应日期范围
            return [goalTask.dateRange.interval]
            
        case let .content(oldValue, newValue):
            return [oldValue.dateRange.interval, newValue.dateRange.interval]
            
        default:
            return affectedRanges(for: [goalTask])
        }
    }
}

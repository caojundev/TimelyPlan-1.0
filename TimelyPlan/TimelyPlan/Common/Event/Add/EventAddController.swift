//
//  EventAddController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/28.
//

import Foundation

class EventAddController {
    
    weak var quickAddManager: TodoTaskQuickAddManager?
 
    func performAddMenuAction(with type: EventAddType, on date: Date) {
        let currentDate = Date()
        let startDate = date.dateByReplacingHour(with: currentDate.hour)
        guard let endDate = startDate.dateByAddingHours(1) else {
            return
        }

        let dateInfo = TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: false)
        performAddMenuAction(with: type, with: dateInfo)
    }
    
    func performAddMenuAction(with type: EventAddType, with dateInfo: TaskDateInfo) {
        switch type {
        case .bind:
            bindTask(with: dateInfo)
        case .calendar:
            createCalendarEvent(with: dateInfo)
        case .todo:
            showQuickAddTask(with: dateInfo)
        case .habit:
            createNewHabit(with: dateInfo)
        case .focus:
            createNewTimer(with: dateInfo)
        case .goal:
            createNewGoalTask(with: dateInfo)
        case .countdown:
            createNewCountdown(with: dateInfo)
        }
    }
    
    private func bindTask(with dateInfo: TaskDateInfo) {
        let vc = MyDayTaskBindViewController(dateInfo: dateInfo)
        vc.showAsNavigationRoot(style: .formSheet, animated: true, completion: nil)
    }
    
    private func createCalendarEvent(with dateInfo: TaskDateInfo) {
        CalendarSystemManager.shared.createNewEvent(with: dateInfo)
    }
    
    
    private func createNewHabit(with dateInfo: TaskDateInfo) {
        let startDate = dateInfo.startDate.startOfDay()
        var task = HabitEditingTask()
        task.dateRange = DateRange(startDate: startDate, endDate: nil)
        task.isAddedToMyDay = true
        
        if dateInfo.isAllDay {
            task.timeOption = .anytime
            task.startTime = 0
            task.duration = 0
        } else {
            task.timeOption = HabitTimeOption.currentPeriod(from: dateInfo.startDate)
            task.startTime = Int64(dateInfo.startDate.offset())
            task.duration = Int64(dateInfo.duration)
        }
        
        HabitPresenter.createNewHabitTask(task: task)
    }

    private func createNewTimer(with dateInfo: TaskDateInfo) {
        let startDate = dateInfo.startDate.startOfDay()
        var timer = FocusEditingTimer()
        timer.dateRange = DateRange(startDate: startDate, endDate: nil)
        timer.isAddedToMyDay = true
        FocusPresenter.createNewTimer(with: timer)
    }

    private func createNewGoalTask(with dateInfo: TaskDateInfo) {
        var editingTask = GoalEditingTask()
        editingTask.startDate = dateInfo.startDate.startOfDay()
        editingTask.endDate = dateInfo.endDate.endOfDay()
        GoalPresenter.createNewInboxGoalTask(editingTask: editingTask)
    }
    
    private func createNewCountdown(with dateInfo: TaskDateInfo) {
        var editingEvent = CountdownEditingEvent.preset(for: .countdown)
        /// 倒数日为全天事项，所选日期即目标日期
        editingEvent.targetDate = dateInfo.startDate.startOfDay()
        /// 从「我的一天」添加，默认在目标日期当天于我的一天中显示
        editingEvent.myDayDisplayMode = .onTheDay
        CountdownPresenter.createNewEvent(type: .countdown, editingEvent: editingEvent)
    }
    
    // MARK: - 添加待办任务
    private func showQuickAddTask(with dateInfo: TaskDateInfo) {
        guard let quickAddManager = quickAddManager else {
            return
        }

        // 检查并清理过期的草稿任务
        if shouldClearDraftTask(with: dateInfo) {
            quickAddManager.clearDraftTask()
        }
        
        let task = TodoQuickAddTask()
        task.schedule = TaskSchedule(dateInfo: dateInfo, reminder: nil, repeatRule: nil)
        task.isAddedToMyDay = true
        quickAddManager.show(with: task)
    }
    
    private func shouldClearDraftTask(with dateInfo: TaskDateInfo) -> Bool {
        guard let draftTask = quickAddManager?.draftTask,
              let draftDateInfo = draftTask.schedule?.dateInfo else {
            return quickAddManager?.draftTask != nil // 无日期信息的草稿需要清理
        }
        
        return draftDateInfo != dateInfo
    }
}

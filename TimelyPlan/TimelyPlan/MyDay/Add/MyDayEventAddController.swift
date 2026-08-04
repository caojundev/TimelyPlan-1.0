//
//  MyDayEventAddController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/28.
//

import Foundation

class MyDayEventAddController {
    
    weak var quickAddManager: TodoTaskQuickAddManager?
 
    func performAddMenuAction(with type: MyDayEventAddType, on date: Date) {
        switch type {
        case .bind:
            bindTask()
        case .todo:
            showQuickAddTask(on: date)
        case .habit:
            createNewHabit(on: date)
        case .focus:
            createNewTimer(on: date)
        }
    }
    
    // MARK: - 绑定任务
    private func bindTask() {
        let vc = MyDayTaskBindViewController()
        vc.showAsNavigationRoot(style: .formSheet, animated: true, completion: nil)
    }
    
    // MARK: - 添加习惯
    private func createNewHabit(on date: Date) {
        let startDate = date.startOfDay()
        var task = HabitEditingTask()
        task.dateRange = DateRange(startDate: startDate, endDate: nil)
        task.isAddedToMyDay = true
        HabitPresenter.createNewHabitTask(task: task)
    }
    
    // MARK: - 添加专注计时器
    private func createNewTimer(on date: Date) {
        let startDate = date.startOfDay()
        var timer = FocusEditingTimer()
        timer.dateRange = DateRange(startDate: startDate, endDate: nil)
        timer.isAddedToMyDay = true
        FocusPresenter.createNewTimer(with: timer)
    }
    
    // MARK: - 添加待办任务
    private func showQuickAddTask(on date: Date) {
        guard let quickAddManager = quickAddManager else {
            return
        }

        // 检查并清理过期的草稿任务
        if shouldClearDraftTask(with: date) {
            quickAddManager.clearDraftTask()
        }

        let task = quickAddTask(on: date)
        quickAddManager.show(with: task)
    }
    
    private func shouldClearDraftTask(with date: Date) -> Bool {
        guard let draftTask = quickAddManager?.draftTask,
              let dateInfo = draftTask.schedule?.dateInfo else {
            return quickAddManager?.draftTask != nil // 无日期信息的草稿需要清理
        }
        
        return !dateInfo.startDate.isInSameDayAs(date)
    }
    
    private func quickAddTask(on date: Date) -> TodoQuickAddTask {
        let dateInfo = TaskDateInfo(date: date)
        let schedule = TaskSchedule(dateInfo: dateInfo,
                                    reminder: nil,
                                    repeatRule: nil)
        let task = TodoQuickAddTask()
        task.schedule = schedule
        task.isAddedToMyDay = true
        return task
    }
    
}

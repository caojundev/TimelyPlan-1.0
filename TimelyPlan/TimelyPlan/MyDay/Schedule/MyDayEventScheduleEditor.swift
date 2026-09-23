//
//  MyDayEventScheduleEditor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/1.
//

import Foundation
import EventKit

class MyDayEventScheduleEditor {
    
    static func editSchedule(for event: MyDayEvent) {
        switch event.source {
        case .calendar:
            if let ekEvent = event.sourceItem as? EKEvent {
                openScheduleEditor(for: ekEvent)
            }
        case .todo:
            if let task = event.sourceItem as? TodoTask {
                openScheduleEditor(for: task)
            }
        case .habit:
            if let task = event.sourceItem as? HabitTask {
                openScheduleEditor(for: task)
            }
        case .goal:
            if let task = event.sourceItem as? GoalTask {
                openScheduleEditor(for: task)
            }
        case .focus:
            if let timer = event.sourceItem as? FocusTimer {
                openScheduleEditor(for: timer)
            }
        case .countdown:
            if let countdownEvent = event.sourceItem as? CountdownEvent {
                openScheduleEditor(for: countdownEvent)
            }
        }
    }
    
    private static func openScheduleEditor(for event: EKEvent) {
        let dateInfo = TaskDateInfo(startDate: event.startDate,
                                    endDate: event.endDate,
                                    isAllDay: event.isAllDay)
        let vc = TaskDateInfoEditViewController(dateInfo: dateInfo)
        vc.showClearButton = false
        vc.didEndEditing = { newDateInfo in
            guard let newDateInfo = newDateInfo else {
                return
            }
            
            CalendarSystemManager.shared.updateEventWithConfirmation(event, with: newDateInfo) { result in
                switch result {
                case .success:
                    debugPrint("事项更新成功")
                case .failure(let error):
                    debugPrint("事项更新失败: \(error.localizedDescription)")
                }
            }
        }
        
        vc.popoverShowAsNavigationRoot()
    }
    
    private static func openScheduleEditor(for task: TodoTask) {
        guard !task.isDetached, let schedule = task.schedule else {
            return
        }
        
        let vc = TodoScheduleEditViewController(schedule: schedule)
        vc.showClearButton = false
        vc.didEndEditing = { newSchedule in
            TodoRepository.updateTask(task, schedule: newSchedule)
        }
        
        vc.popoverShowAsNavigationRoot()
    }

    /// 习惯计划编辑
    private static func openScheduleEditor(for task: HabitTask) {
        let vc = MyDayHabitScheduleEditViewController(task: task.editingTask)
        vc.didEndEditing = { editingTask in
            HabitRepository.updateTask(task, with: editingTask)
        }
        presentAsSheet(vc)
    }

    private static func openScheduleEditor(for timer: FocusTimer) {
        let vc = MyDayFocusScheduleEditViewController(timer: timer.editingTimer)
        vc.didEndEditing = { editingTimer in
            FocusRepository.updateTimer(timer, with: editingTimer)
        }
        presentAsSheet(vc)
    }
    
    /// 目标计划编辑
    private static func openScheduleEditor(for task: GoalTask) {
        let vc = MyDayGoalScheduleEditViewController(goalTask: task.editingTask)
        vc.didEndEditing = { editingTask in
            GoalRepository.updateGoalTask(task, with: editingTask)
        }
        presentAsSheet(vc)
    }
    
    /// 倒数日事项（全天事项，无时间计划编辑，直接展示详情）
    private static func openScheduleEditor(for event: CountdownEvent) {
        CountdownPresenter.showDetail(for: event)
    }
    
    /// 以 sheet 形式展示 ViewController
    private static func presentAsSheet(_ viewController: UIViewController) {
        if let sheet = viewController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        viewController.show()
    }
    
}

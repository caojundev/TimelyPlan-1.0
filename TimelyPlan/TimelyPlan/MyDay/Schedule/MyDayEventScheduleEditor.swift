//
//  MyDayEventScheduleEditor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/1.
//

import Foundation

class MyDayEventScheduleEditor {
    
    static func editSchedule(for event: MyDayEvent) {
        switch event.source {
        case .todo:
            if let task = event.sourceItem as? TodoTask {
                openScheduleEditor(for: task)
            }
        case .habit:
            if let task = event.sourceItem as? HabitTask {
                openScheduleEditor(for: task)
            }
        case .focus:
            if let timer = event.sourceItem as? FocusTimer {
                openScheduleEditor(for: timer)
            }
        }
    }
    
    /// 习惯计划编辑
    private static func openScheduleEditor(for task: HabitTask) {
        let vc = MyDayHabitScheduleEditViewController(task: task.editingTask)
        vc.didEndEditing = { editingTask in
            HabitRepository.updateTask(task, with: editingTask)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        if let sheet = navController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        navController.show()
    }
    
    private static func openScheduleEditor(for task: TodoTask) {
        print(task.displayName)
    }
    
    private static func openScheduleEditor(for timer: FocusTimer) {
        let vc = MyDayFocusScheduleEditViewController(timer: timer.editingTimer)
        vc.didEndEditing = { editingTimer in
            FocusRepository.updateTimer(timer, with: editingTimer)
        }

        let navController = UINavigationController(rootViewController: vc)
        if let sheet = navController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        navController.show()
    }
}

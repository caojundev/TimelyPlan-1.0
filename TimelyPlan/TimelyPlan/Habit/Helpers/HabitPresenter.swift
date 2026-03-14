//
//  HabitPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation

class HabitPresenter {
    
    /// 显示统计试图
    static func showStats(for task: HabitTask, date: Date = .now) {
        let vc = HabitStatsMainViewController(task: task, type: .month, date: date)
        vc.showAsNavigationRoot()
    }
    
    /// 显示习惯管理视图控制器
    static func manageHabits() {
        let vc = HabitManageMainViewController()
        vc.showAsNavigationRoot()
    }
    
    /// 创建新习惯
    static func createNewHabitTask() {
        let vc = HabitTaskEditViewController(task: nil)
        vc.didEndEditing = { editingTask in
            habit.createTask(with: editingTask)
        }
        
        vc.showAsNavigationRoot()
    }
    
    /// 编辑习惯
    static func editHabitTask(_ task: HabitTask) {
        let vc = HabitTaskEditViewController(task: task.editingTask)
        vc.didEndEditing = { editingTask in
            habit.updateTask(task, with: editingTask)
        }
        
        vc.showAsNavigationRoot()
    }
    
    /// 显示设置视图控制器
    static func showSettings() {
        let vc = HabitSettingViewController(style: .insetGrouped)
        vc.showAsNavigationRoot()
    }

}

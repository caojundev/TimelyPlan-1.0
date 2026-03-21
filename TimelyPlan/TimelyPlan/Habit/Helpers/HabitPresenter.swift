//
//  HabitPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation

class HabitPresenter {
    /// 显示记录
    static func showRecords() {
        let vc = HabitRecordsViewController()
        vc.showAsNavigationRoot()
    }
    
    /// 显示报告
    static func showReport() {
        let vc = HabitReportMainViewController()
        vc.showAsNavigationRoot()
    }
    
    /// 显示统计
    static func showStats(for task: HabitTask, date: Date = .now) {
        let vc = HabitStatsMainViewController(task: task, type: .month, date: date)
        vc.showAsNavigationRoot()
    }
    
    /// 显示习惯管理视图控制器
    static func manageHabits(menuType: HabitManageListType = .active) {
        let vc = HabitManageMainViewController(menuType: menuType)
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
    
    // MARK: - 记录相关操作
    /// 确认删除记录
    static func confirmRecordDeletion(completion: @escaping(Bool) -> Void) {
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            completion(true)
        }
        
        /// 在 dismiss 后处理回调
        deleteAction.handleBeforeDismiss = false
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel")) { action in
            completion(false)
        }
        
        let message = resGetString("Sure to delete this habit record?")
        let alertController = TPAlertController(title: resGetString("Delete Record"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }

}

//
//  GoalTaskController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/4.
//

import Foundation

class GoalTaskController {
    
    func performMenuAction(_ type: GoalTaskMenuType, for task: GoalTask) {
        switch type {
        case .addToMyDay:
            GoalRepository.updateGoalTask(task, isAddedToMyDay: true)
        case .removeFromMyDay:
            GoalRepository.updateGoalTask(task, isAddedToMyDay: false)
        case .startFocus:
            FocusPresenter.quickStartFocus(for: task)
        case .edit:
            GoalPresenter.editGoalTask(task)
        case .delete:
            deleteTask(task)
        }
    }
    
    /// 弹窗确认删除任务
    func deleteTask(_ task: GoalTask){
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            GoalRepository.deleteGoalTask(task)
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        
        let format: String = resGetString("\"%@\" will be permanently deleted.")
        let message = String(format: format, task.displayName)
        let alertController = TPAlertController(title: resGetString("Delete Goal Task"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }

}

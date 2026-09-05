//
//  GoalPlanMenuProcessor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

class GoalPlanMenuProcessor {
    
    func performMenuAction(_ type: GoalPlanMenuType, for goalPlan: GoalPlan) {
        switch type {
        case .edit:
            GoalPresenter.editGoalPlan(goalPlan)
        case .archive:
            GoalRepository.archiveGoalPlan(goalPlan)
        case .unarchive:
            GoalRepository.unarchiveGoalPlan(goalPlan)
        case .delete:
            deleteGoalPlan(goalPlan)
        }
    }
    
    /// 弹窗确认删除计划
    func deleteGoalPlan(_ goalPlan: GoalPlan){
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            GoalRepository.deleteGoalPlan(goalPlan)
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        
        let format: String = resGetString("\"%@\" will be permanently deleted.")
        let message = String(format: format, goalPlan.displayName)
        let alertController = TPAlertController(title: resGetString("Delete Goal Plan"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }

}


//
//  GoalPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

class GoalPresenter {
    
    /// 创建新目标
    static func createNewGoalPlan(_ goalPlan: GoalEditingPlan? = nil) {
        let vc = GoalPlanEditViewController(goalPlan: goalPlan)
        vc.didEndEditing = { editingPlan in
            GoalRepository.createGoalPlan(with: editingPlan)
        }

        vc.showAsNavigationRoot()
    }
    
    /// 编辑目标
    static func editGoalPlan(_ goalPlan: GoalPlan) {
        let vc = GoalPlanEditViewController(goalPlan: goalPlan.editingPlan)
        vc.didEndEditing = { editingPlan in
            GoalRepository.updateGoalPlan(goalPlan, with: editingPlan)
        }

        vc.showAsNavigationRoot()
    }
    
    /// 显示设置
    static func showSetting() {
        let vc = GoalSettingViewController()
        vc.showAsNavigationRoot()
    }
    
    /// 显示已归档目标计划
    static func showArchived() {
        let vc = GoalArchivedViewController()
        vc.showAsNavigationRoot()
    }
    
    /// 显示已归档目标计划详情
    static func showArchivedGoalDetail(_ goalPlan: GoalPlan) {
        let vc = GoalDetailViewController(goalPlan: goalPlan)
        vc.showAsNavigationRoot()
    }
}

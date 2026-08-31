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
        case .moveToTop:
            GoalRepository.moveGoalPlanToTop(goalPlan)
        case .moveToBottom:
            GoalRepository.moveGoalPlanToBottom(goalPlan)
        case .edit:
            GoalPresenter.editGoalPlan(goalPlan)
        case .archive:
            GoalRepository.archiveGoalPlan(goalPlan)
        case .unarchive:
            GoalRepository.unarchiveGoalPlan(goalPlan)
        case .delete:
            GoalRepository.deleteGoalPlan(goalPlan)
        }
    }
}

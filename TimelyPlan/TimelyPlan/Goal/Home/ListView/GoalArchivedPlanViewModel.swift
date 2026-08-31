//
//  GoalArchivedPlanViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

class GoalArchivedPlanViewModel: GoalPlanViewModel {
    
    override init() {
        super.init()
        
        self.placeholderProvider.emptyImage = resGetImage("archivedList_80")
        self.placeholderProvider.emptyTitle = resGetString("No Archived Goal")
    }
    
    override func fetchGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        GoalRepository.fetchArchivedGoalPlans(completion: completion)
    }
}

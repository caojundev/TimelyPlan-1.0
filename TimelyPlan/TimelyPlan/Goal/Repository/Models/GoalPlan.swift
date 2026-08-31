//
//  GoalPlan.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

class GoalPlan {
    
    
    var editingPlan: GoalEditingPlan {
        return GoalEditingPlan()
    }
}


struct GoalEditingPlan {
    
    var name: String?
    
    var color: UIColor = GoalConfig.goalPlanDefaultColor

    var startDate: Date?
    
    var endDate: Date?
    
    var note: String?
}

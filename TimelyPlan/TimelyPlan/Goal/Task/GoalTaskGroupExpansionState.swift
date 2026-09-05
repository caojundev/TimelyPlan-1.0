//
//  GoalTaskGroupExpansionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/5.
//

import Foundation

class GoalTaskGroupExpansionState: ExpansionStateProviding {
    
    private var collapsedStates: [String: Bool]
    
    let identifier: String
    
    init(goalPlan: GoalPlan) {
        self.identifier = goalPlan.identifier
        self.collapsedStates = GoalState.shared.groupStates(for: goalPlan.identifier) ?? [:]
    }

    func isExpanded(_ item: Any) -> Bool {
        let group = item as! GoalTaskGroup
        let isCollapsed = collapsedStates[group.identifier] ?? false
        return !isCollapsed
    }
    
    func setExpended(_ isExpended: Bool, for item: Any) {
        let group = item as! GoalTaskGroup
        if isExpended {
            collapsedStates[group.identifier] = nil
        } else {
            collapsedStates[group.identifier] = true
        }
        
        GoalState.shared.setGroupStates(collapsedStates, for: identifier)
    }
}


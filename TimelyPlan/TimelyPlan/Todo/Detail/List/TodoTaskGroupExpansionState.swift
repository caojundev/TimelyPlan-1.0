//
//  TodoTaskGroupExpansionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/6.
//

import Foundation

class TodoTaskGroupExpansionState: ExpansionStateProviding {
    
    private var collapsedStates: [String: Bool]
    
    let identifier: String
    init(identifier: String) {
        self.identifier = identifier
        self.collapsedStates = TodoState.shared.groupStates(for: identifier) ?? [:]
    }

    func isExpanded(_ item: Any) -> Bool {
        let group = item as! TodoGroup
        let isCollapsed = collapsedStates[group.identifier] ?? false
        return !isCollapsed
    }
    
    func setExpended(_ isExpended: Bool, for item: Any) {
        let group = item as! TodoGroup
        if isExpended {
            collapsedStates[group.identifier] = nil
        } else {
            collapsedStates[group.identifier] = true
        }
        
        TodoState.shared.setGroupStates(self.collapsedStates, for: self.identifier)
    }
}


//
//  TodoTaskGroupExpansionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/6.
//

import Foundation

class TodoTaskGroupExpansionState: ExpansionStateProviding {
    
    private var collapsedGroups = Set<String>()
    
    func isExpanded(_ item: Any) -> Bool {
        let group = item as! TodoGroup
        return !collapsedGroups.contains(group.identifier)
    }
    
    func setExpended(_ isExpended: Bool, for item: Any) {
        let group = item as! TodoGroup
        if isExpended {
            collapsedGroups.remove(group.identifier)
        } else {
            collapsedGroups.insert(group.identifier)
        }
    }
}


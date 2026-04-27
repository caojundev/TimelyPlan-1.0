//
//  TodoHomeUserListExpansionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/31.
//

import Foundation

class TodoHomeUserListExpansionState: ExpansionStateProviding {
    
    private var collapsedStates: [String: Bool]
    
    init() {
        self.collapsedStates = TodoState.shared.collapsedListStates ?? [:]
    }
    
    func isExpanded(_ item: Any) -> Bool {
        let list = item as! TodoList
        let isCollapsed = collapsedStates[list.identifier] ?? false
        return !isCollapsed
    }
    
    func setExpended(_ isExpended: Bool, for item: Any) {
        let list = item as! TodoList
        if isExpended {
            collapsedStates[list.identifier] = nil
        } else {
            collapsedStates[list.identifier] = true
        }
        
        TodoState.shared.collapsedListStates = collapsedStates
    }
}

//
//  TodoHomeUserListExpansionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/31.
//

import Foundation

class TodoHomeUserListExpansionState: ExpansionStateProviding {
    
    private var collapsedLists = Set<TodoList>()
    
    func isExpanded(_ item: Nestable) -> Bool {
        let list = item as! TodoList
        return !collapsedLists.contains(list)
    }
    
    func setExpended(_ isExpended: Bool, for item: Nestable) {
        let list = item as! TodoList
        if isExpended {
            collapsedLists.remove(list)
        } else {
            collapsedLists.insert(list)
        }
    }
    
}

//
//  TodoHomeUserListExpansionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/31.
//

import Foundation

class TodoHomeUserListExpansionState: ExpansionStateProviding {
    
    private var collapsedLists = Set<String>()
    
    func isExpanded(_ item: Any) -> Bool {
        let list = item as! TodoList
        return !collapsedLists.contains(list.identifier)
    }
    
    func setExpended(_ isExpended: Bool, for item: Any) {
        let list = item as! TodoList
        if isExpended {
            collapsedLists.remove(list.identifier)
        } else {
            collapsedLists.insert(list.identifier)
        }
    }
    
    /// 展开清单所有父清单
    func expandAllParentList(of list: TodoList, includeCurrent: Bool = true) {
        if includeCurrent {
            setExpended(true, for: list)
        }
        
        var parent = list.parent
        while parent != nil {
            setExpended(true, for: parent!)
            parent = parent?.parent
        }
    }
}

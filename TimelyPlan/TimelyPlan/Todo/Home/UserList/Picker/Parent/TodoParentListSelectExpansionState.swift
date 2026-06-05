//
//  TodoParentListSelectExpansionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/5.
//

import Foundation

class TodoParentListSelectExpansionState: ExpansionStateProviding {
    
    /// 允许的最大列表深度
    let allowMaxDepth: Int
    
    /// 禁止选择列表数组
    var disabledLists: [TodoList]?
    
    private var collapsedLists = Set<TodoList>()
    
    init(allowMaxDepth: Int) {
        self.allowMaxDepth = allowMaxDepth
    }
    
    func canSetExpended(_ isExpended: Bool, for item: Any) -> Bool {
        let list = item as! TodoList
        return list.depth < allowMaxDepth
    }

    func isExpanded(_ item: Any) -> Bool {
        let list = item as! TodoList
        if list.depth >= allowMaxDepth || collapsedLists.contains(list) {
            return false
        }
        
        guard let disabledLists = disabledLists else {
            return true
        }
        
        return !disabledLists.contains(list)
    }
    
    func setExpended(_ isExpended: Bool, for item: Any) {
        let list = item as! TodoList
        if isExpended {
            collapsedLists.remove(list)
        } else {
            collapsedLists.insert(list)
        }
    }
    
    /// 是否为禁用列表
    func isDisabledList(_ list: TodoList) -> Bool {
        if list.depth > allowMaxDepth {
            return true
        }
        
        if let disabledLists = disabledLists {
            return disabledLists.contains(list)
        }
        
        return false
    }
}

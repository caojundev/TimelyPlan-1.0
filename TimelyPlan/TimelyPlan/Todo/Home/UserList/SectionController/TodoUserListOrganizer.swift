//
//  TodoUserListOrganizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

class TodoUserListOrganizer {
    
    static let shared = TodoUserListOrganizer()
    
    private var topLists: [TodoList]?
    
    /// 获取用户列表数组
    func userLists(with stateProvier: ExpansionStateProviding) -> [TodoList] {
        let topLists = CDTodoList.getTopLists()?.userLists
        guard let topLists = topLists else {
            return []
        }

        let lists = topLists.flattenItems(with: stateProvier) as? [TodoList]
        return lists ?? []
    }
    
}

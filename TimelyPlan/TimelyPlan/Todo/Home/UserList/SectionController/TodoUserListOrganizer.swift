//
//  TodoUserListOrganizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

class TodoUserListOrganizer {
    
    private var topLists: [TodoList]?
    
    init() {
        var lists = [TodoList]()
        for _ in  0...2 {
            let list = TodoList()
            var sublists = [TodoList]()
            for _ in 0...3 {
                let sublist1 = TodoList()
                sublist1.parent = list
                
                var sublists2 = [TodoList]()
                for _ in 0...3 {
                    let sublist2 = TodoList()
                    sublist2.parent = sublist1
                    sublists2.append(sublist2)
                }
                
                sublist1.sublists = sublists2
                sublists.append(sublist1)
            }
            
            list.sublists = sublists
            lists.append(list)
        }
        
        self.topLists = lists
    }
    
    /// 获取用户列表数组
    func userLists(shouldExpand: ((Nestable) -> Bool)? = nil) -> [TodoList] {
        guard let topLists = topLists else {
            return []
        }

        let lists = topLists.flattenItems(shouldExpand: shouldExpand) as? [TodoList]
        return lists ?? []
    }
    
}

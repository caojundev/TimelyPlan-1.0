//
//  TodoListMenuActionController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/6.
//

import Foundation

class TodoListMenuActionController: TPBaseMenuController<TodoListMenuActionType> {
    
    /// 菜单作用的列表
    let list: TodoList

    init(list: TodoList) {
        self.list = list
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<TodoListMenuActionType>] {
        var lists: [Array<TodoListMenuActionType>]
        lists = [[.addSublist],
                 [.move, .ungroup],
                 [.edit],
                 [.delete]]
        return lists
    }
    
    override func menuActionTypes() -> [TodoListMenuActionType] {
        var types: [TodoListMenuActionType] = [.edit,
                                               .move]
        
        if !list.hasSubItem {
            types.append(.delete)
        }
        
        if list.depth < kTodoListMaxDepth {
            types.append(.addSublist)
        }
        
        if list.allSubItemsCount > 0 {
            types.append(.ungroup)
        }
        
        return types
    }
}


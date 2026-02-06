//
//  TodoListMenuActionController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/6.
//

import Foundation

/// 待办列表操作菜单
enum TodoListMenuActionType: String, TPMenuRepresentable {
    case move    /// 移动列表
    case edit    /// 编辑
    case delete  /// 删除
    
    var iconName: String? {
        switch self {
        case .move:
            return "todo_list_move_24"
        case .edit:
            return "edit_24"
        case .delete:
            return "shred_24"
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        if self == .delete {
            return .destructive
        }
        
        return .normal
    }
}

class TodoListMenuActionController: TPBaseMenuController<TodoListMenuActionType> {
    
    /// 菜单作用的列表
    let list: TodoList

    init(list: TodoList) {
        self.list = list
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<TodoListMenuActionType>] {
        var lists: [Array<TodoListMenuActionType>]
        lists = [[.move, .edit],
                 [.delete]]
        return lists
    }
    
    override func menuActionTypes() -> [TodoListMenuActionType] {
        var types: [TodoListMenuActionType] = [.edit,
                                               .move,
                                               .delete]
        
        return types
    }
}


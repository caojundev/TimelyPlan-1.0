//
//  TodoListMenuActionType.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/6.
//

import Foundation

/// 待办列表操作菜单
enum TodoListMenuActionType: String, TPMenuRepresentable {
    
    case addSublist /// 添加子列表
    case ungroup    /// 解散子列表
    case move       /// 移动列表
    case edit       /// 编辑
    case delete     /// 删除
    
    var title: String {
        switch self {
        case .addSublist:
            return resGetString("Add Sublist")
        case .move:
            return resGetString("Move List")
        case .ungroup:
            return resGetString("Ungroup List")
        case .edit:
            return resGetString("Edit")
        case .delete:
            return resGetString("Delete")
        }
    }
    
    var iconName: String? {
        switch self {
        case .addSublist:
            return "todo_list_addSublist_24"
        case .ungroup:
            return "todo_list_ungroup_24"
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

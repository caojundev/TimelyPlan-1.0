//
//  TodoFilterMenuActionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/29.
//

import Foundation

/// 待办标签操作菜单
enum TodoFilterMenuActionType: String, TPMenuRepresentable {
    case edit        /// 编辑
    case delete      /// 删除
    
    static func titles() -> [String] {
        return ["Edit", "Delete"]
    }
    
    var iconName: String? {
        switch self {
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

class TodoFilterMenuActionController: TPBaseMenuController<TodoFilterMenuActionType> {
    
    override func orderedMenuActionTypeLists() -> [Array<TodoFilterMenuActionType>] {
        var lists: [Array<TodoFilterMenuActionType>]
        lists = [[.edit],
                 [.delete]]
        return lists
    }
}

//
//  TodoTagMenuActionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/29.
//

import Foundation

/// 待办标签操作菜单
enum TodoTagMenuActionType: String, TPMenuRepresentable {
    case edit        /// 编辑
    case delete      /// 删除
    
    var title: String {
        return rawValue.capitalized
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

class TodoTagMenuActionController: TPBaseMenuController<TodoTagMenuActionType> {
    
    override func orderedMenuActionTypeLists() -> [Array<TodoTagMenuActionType>] {
        var lists: [Array<TodoTagMenuActionType>]
        lists = [[.edit],
                 [.delete]]
        return lists
    }
}

//
//  TodoFolderMenuActionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/2.
//

import Foundation

/// 目录操作菜单
enum TodoFolderMenuActionType: String, TPMenuRepresentable {
    
    case addList   /// 添加列表
    case ungroup  /// 解散
    case edit     /// 编辑
    case delete   /// 删除
    
    var title: String {
        switch self {
        case .addList:
            return "Add List"
        default:
            return rawValue.capitalized
        }
    }
    
    var iconName: String? {
        switch self {
        case .edit:
            return "edit_24"
        case .delete:
            return "shred_24"
        default:
            return "todo_folder_" + rawValue + "_24"
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        if self == .delete || self == .ungroup {
            return .destructive
        }
        
        return .normal
    }
}

class TodoFolderMenuActionController: TPBaseMenuController<TodoFolderMenuActionType> {
    
    let folder: TodoFolder

    init(folder: TodoFolder) {
        self.folder = folder
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<TodoFolderMenuActionType>] {
        var types: [Array<TodoFolderMenuActionType>]
        types = [[.addList],
                 [.edit],
                 [.ungroup, .delete]]
        return types
    }
    
    override func menuActionTypes() -> [TodoFolderMenuActionType] {
        var types: [TodoFolderMenuActionType] = [.addList, .edit]
        let listCount = folder.lists?.count ?? 0
        if listCount > 0 {
            types.append(.ungroup)
        } else {
            types.append(.delete)
        }

        return types
    }
}


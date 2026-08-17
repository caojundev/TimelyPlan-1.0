//
//  TodoListOption.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/23.
//

import Foundation

enum TodoListOption: String, TPMenuRepresentable {
    case select    /// 选择
    case showCompleted /// 显示已完成
    case showDetail    /// 显示详情
    case layout    /// 视图布局
    case group     /// 分组
    case sort      /// 排序
    case edit      /// 编辑列表
    case delete    /// 删除列表
    case emptyTrash /// 清空废纸篓
    case manageSection /// 管理分区
    case search     /// 搜索
    case importTask /// 导入任务
    case print      /// 打印
    
    /// 图标名称
    var iconName: String? {
        switch self {
        case .search:
            return "search_24"
        case .edit:
            return "edit_24"
        case .delete:
            return "shred_24"
        case .emptyTrash:
            return "trash_empty_24"
        default:
            return "todo_list_option_" + rawValue + "_24"
        }
    }
    
    /// 标题
    var title: String {
        switch self {
        case .select:
            return resGetString("Select")
        case .showCompleted:
            return resGetString("Show Completed")
        case .showDetail:
            return resGetString("Show Detail")
        case .layout:
            return resGetString("Layout")
        case .group:
            return resGetString("Group")
        case .sort:
            return resGetString("Sort")
        case .edit:
            return resGetString("Edit")
        case .delete:
            return resGetString("Delete")
        case .emptyTrash:
            return resGetString("Empty Trash")
        case .manageSection:
            return resGetString("Manage Section")
        case .importTask:
            return resGetString("Import Task")
        case .search:
            return resGetString("Search")
        case .print:
            return resGetString("Print List")
        }
    }

    /// 菜单动作样式
    var actionStyle: TPMenuActionStyle {
        switch self {
        case .delete, .emptyTrash:
            return .destructive
        default:
            return .normal
        }
    }
    
    var handleBeforeDismiss: Bool {
        switch self {
        case .select, .showCompleted, .showDetail:
            return true
        default:
            return false
        }
    }
}

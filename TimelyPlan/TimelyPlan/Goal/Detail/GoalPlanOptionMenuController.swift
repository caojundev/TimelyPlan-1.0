//
//  GoalPlanOptionMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

enum GoalPlanOption: String, TPMenuRepresentable {
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


/// 目标计划选项配置
struct GoalPlanOptionConfig {
    
    let options: [GoalPlanOption]
    
    let groupType: TodoGroupType
    
    let sort: TodoSort
    
    var showCompleted: Bool = true
    
    var showDetail: Bool = true
    
    var layoutType: TodoListLayoutType = .list
    
    /// 允许的分组类型
    var allowGroupTypes: [TodoGroupType] = []
    
    /// 允许的排序类型
    var allowSortTypes: [TodoSortType] = []
    
    /// 允许的排列顺序
    var allowSortOrders: [TodoSortOrder] = []
    
    static func config(with state: TodoListOptionState,
                       configuration: TodoListConfiguration) -> TodoListOptionConfig? {
        guard let options = configuration.allowListOptions(), options.count > 0 else {
            return nil
        }
        
        let groupType = state.validatedGroupType(for: configuration)
        let sort = state.validatedSort(for: configuration)
        var config = TodoListOptionConfig(options: options, groupType: groupType, sort: sort)
        config.showCompleted = state.showCompleted
        config.showDetail = state.showDetail
        config.layoutType = state.layoutType ?? .list
        config.allowGroupTypes = configuration.allowGroupTypes()
        config.allowSortTypes = configuration.allowSortTypes()
        config.allowSortOrders = configuration.allowSortOrders(for: sort.type)
        return config
    }
}

class GoalPlanOptionMenuController: TPBaseMenuController<GoalPlanOption> {
    
    /// 选中选项
    var didSelectOption: ((GoalPlanOption) -> Void)?
    
    let config: GoalPlanOptionConfig
    
    init(config: GoalPlanOptionConfig) {
        self.config = config
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<GoalPlanOption>] {
        return [[.edit, .delete]]
    }
    
    override func menuActionTypes() -> [GoalPlanOption] {
        return config.options
    }
    
    override func updateMenuAction(_ action: TPMenuAction, for type: GoalPlanOption) {
        action.handler = { _ in
            self.didSelectOption?(type)
        }
    }
}

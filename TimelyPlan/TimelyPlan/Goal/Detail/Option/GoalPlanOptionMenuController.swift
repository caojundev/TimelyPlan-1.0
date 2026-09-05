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
    case group     /// 分组
    case sort      /// 排序
    case edit      /// 编辑列表
    case delete    /// 删除列表

    /// 图标名称
    var iconName: String? {
        switch self {
        case .edit:
            return "edit_24"
        case .delete:
            return "shred_24"
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
        case .group:
            return resGetString("Group")
        case .sort:
            return resGetString("Sort")
        case .edit:
            return resGetString("Edit")
        case .delete:
            return resGetString("Delete")
        }
    }

    /// 菜单动作样式
    var actionStyle: TPMenuActionStyle {
        switch self {
        case .delete:
            return .destructive
        default:
            return .normal
        }
    }
    
    var handleBeforeDismiss: Bool {
        switch self {
        case .select, .showCompleted:
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

    /// 允许的分组类型
    var allowGroupTypes: [TodoGroupType] = []
    
    /// 允许的排序类型
    var allowSortTypes: [TodoSortType] = []
    
    /// 允许的排列顺序
    var allowSortOrders: [TodoSortOrder] = []
    
    static func config(with state: GoalPlanOptionState,
                       configuration: GoalPlanConfiguration) -> GoalPlanOptionConfig? {
        guard let options = configuration.allowOptions(), options.count > 0 else {
            return nil
        }
        
        let groupType = state.validatedGroupType(for: configuration)
        let sort = state.validatedSort(for: configuration)
        var config = GoalPlanOptionConfig(options: options, groupType: groupType, sort: sort)
        config.showCompleted = state.showCompleted
        config.allowGroupTypes = configuration.allowGroupTypes()
        config.allowSortTypes = configuration.allowSortTypes()
        config.allowSortOrders = configuration.allowSortOrders(for: sort.type)
        return config
    }
}

class GoalPlanOptionMenuController: TPBaseMenuController<GoalPlanOption> {

    /// 选中选项
    var didSelectPlanOption: ((GoalPlanOption) -> Void)?
    
    var didSelectGroupType: ((TodoGroupType) -> Void)?
    
    var didSelectSortType: ((TodoSortType) -> Void)?
    
    var didSelectSortOrder: ((TodoSortOrder) -> Void)?
    
    let config: GoalPlanOptionConfig
    
    init(config: GoalPlanOptionConfig) {
        self.config = config
        super.init()
    }

    override func orderedMenuActionTypeLists() -> [Array<GoalPlanOption>] {
        var lists: [Array<GoalPlanOption>]
        lists = [[.showCompleted],
                 [.group, .sort],
                 [.edit],
                 [.delete]]
        return lists
    }
     
    /// 是否显示排序选项
    private var shouldShowSortOption: Bool {
        return config.allowSortTypes.count > 1 || config.allowSortOrders.count > 1
    }

    override func menuActionTypes() -> [GoalPlanOption] {
        var options = [GoalPlanOption]()
        for option in self.config.options {
            if option == .group, config.allowGroupTypes.count > 1 {
                options.append(.group)
            } else if option == .sort, shouldShowSortOption {
                options.append(.sort)
            } else {
                options.append(option)
            }
        }
        
        return options
    }
    
    override func updateMenuAction(_ action: TPMenuAction, for type: GoalPlanOption) {
        action.handler = { _ in
            self.didSelectPlanOption?(type)
        }
        
        switch type {
        case .showCompleted:
            action.isChecked = config.showCompleted
        case .group:
            updateGroupAction(action)
        case .sort:
            updateSortAction(action)
        default:
            break
        }
    }
    
    private func updateGroupAction(_ action: TPMenuAction) {
        action.subtitle = config.groupType.title
        
        let controller = TodoGroupTypeMenuController(types: config.allowGroupTypes)
        controller.selectedGroupType = config.groupType
        controller.didSelectGroupType = didSelectGroupType
        
        let subMenuItems = controller.menuItems()
        let menuItemsCount = subMenuItems.count
        
        // 只有当有多个菜单项，或者单个菜单项包含多个子动作时，才设置子菜单
        let shouldShowSubMenu = menuItemsCount > 1 || subMenuItems.first?.actions?.count ?? 0 > 1
        if shouldShowSubMenu {
            action.subMenuItems = subMenuItems
        }
    }
    
    private func updateSortAction(_ action: TPMenuAction) {
        let sort = config.sort
        var subMenuItems = [TPMenuItem]()
        
        let allowSortTypes = self.config.allowSortTypes
        if allowSortTypes.count > 1 {
            let sortTypeMenuItem = sortTypeMenuItem(allowSortTypes: allowSortTypes,
                                                    sortType: sort.type)
            subMenuItems.append(sortTypeMenuItem)
        }
        
        let allowSortOrders = self.config.allowSortOrders
        if allowSortOrders.count > 1 {
            let sortOrderMenuItem = sortOrderMenuItem(allowSortOrders: allowSortOrders,
                                                      sortOrder: sort.order)
            subMenuItems.append(sortOrderMenuItem)
        }
        
        if subMenuItems.count > 0 {
            action.subMenuItems = subMenuItems
        }
        
        action.subtitle = "\(sort.type.title)•\(sort.order.title)"
    }
    
    private func sortTypeMenuItem(allowSortTypes: [TodoSortType], sortType: TodoSortType) -> TPMenuItem {
        let menuItem = TPMenuItem.item(with: allowSortTypes) { type, action in
            action.handleBeforeDismiss = true
            action.isChecked = type == sortType
            action.handler = { _ in
                self.didSelectSortType?(type)
            }
        }
        
        return menuItem
    }
    
    private func sortOrderMenuItem(allowSortOrders: [TodoSortOrder],
                                   sortOrder: TodoSortOrder) -> TPMenuItem {
        let menuItem = TPMenuItem.item(with: allowSortOrders) { order, action in
            action.handleBeforeDismiss = true
            action.isChecked = order == sortOrder
            action.handler = { _ in
                self.didSelectSortOrder?(order)
            }
        }
        
        return menuItem
    }
}



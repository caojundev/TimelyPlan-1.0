//
//  TodoListOptionMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/25.
//

import Foundation

struct TodoListOptionConfig {
    
    let options: [TodoListOption]
    
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

class TodoListOptionMenuController: TPBaseMenuController<TodoListOption> {

    var didSelectListOption: ((TodoListOption) -> Void)?
    
    var didSelectGroupType: ((TodoGroupType) -> Void)?
    
    var didSelectSortType: ((TodoSortType) -> Void)?
    
    var didSelectSortOrder: ((TodoSortOrder) -> Void)?
    
    let config: TodoListOptionConfig
    
    init(config: TodoListOptionConfig) {
        self.config = config
        super.init()
    }

    override func orderedMenuActionTypeLists() -> [Array<TodoListOption>] {
        var lists: [Array<TodoListOption>]
        lists = [[.select,
                  .showCompleted,
                  .showDetail],
                 [.layout],
                 [.group, .sort],
                 [.edit],
                 [.emptyTrash]]
        return lists
    }
     
    /// 是否显示排序选项
    private var shouldShowSortOption: Bool {
        return config.allowSortTypes.count > 1 || config.allowSortOrders.count > 1
    }

    override func menuActionTypes() -> [TodoListOption] {
        var options = [TodoListOption]()
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
    
    override func updateMenuAction(_ action: TPMenuAction, for type: TodoListOption) {
        action.handler = { _ in
            self.didSelectListOption?(type)
        }
        
        switch type {
        case .showCompleted:
            action.isChecked = config.showCompleted
        case .showDetail:
            action.isChecked = config.showDetail
        case .layout:
            action.subtitle = config.layoutType.title
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


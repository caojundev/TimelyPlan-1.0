//
//  TodoListOptionMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/25.
//

import Foundation

struct TodoListOptionConfig {
    
    var options: [TodoListOption]
    
    var showCompleted: Bool = true
    
    var layoutType: TodoListLayoutType = .list

    var groupType: TodoGroupType = .priority
    
    var sort: TodoSort = TodoSort()
    
    /// 允许的分组类型
    var allowGroupTypes: [TodoGroupType]?
    
    /// 允许的排序类型
    var allowSortTypes: [TodoSortType]?
    
    /// 允许的排列顺序
    var allowSortOrders: [TodoSortOrder]?
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
                  .showCompleted],
                 [.layout],
                 [.group, .sort],
                 [.edit],
                 [.emptyTrash]]
        return lists
    }
    
    override func menuActionTypes() -> [TodoListOption] {
        return self.config.options
    }
    
    override func updateMenuAction(_ action: TPMenuAction, for type: TodoListOption) {
        action.handler = { _ in
            self.didSelectListOption?(type)
        }
        
        switch type {
        case .showCompleted:
            action.isChecked = config.showCompleted
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
        action.subtitle = self.config.groupType.title
        guard let groupTypes = self.config.allowGroupTypes else {
            return
        }
        
        let controller = TodoGroupTypeMenuController(types: groupTypes)
        controller.selectedGroupType = self.config.groupType
        controller.didSelectGroupType = self.didSelectGroupType
        action.subMenuItems = controller.menuItems()
    }
    
    private func updateSortAction(_ action: TPMenuAction) {
        let sort = config.sort
        var subMenuItems = [TPMenuItem]()
        if let allowSortTypes = self.config.allowSortTypes, allowSortTypes.count > 0 {
            let sortTypeMenuItem = sortTypeMenuItem(allowSortTypes: allowSortTypes,
                                                    sortType: sort.type)
            subMenuItems.append(sortTypeMenuItem)
        }
        
        if let allowSortOrders = self.config.allowSortOrders, allowSortOrders.count > 0 {
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


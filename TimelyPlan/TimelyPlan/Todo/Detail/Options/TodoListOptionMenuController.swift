//
//  TodoListOptionMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/25.
//

import Foundation

class TodoListOptionMenuController: TPBaseMenuController<TodoListOption> {

    var didSelectListOption: ((TodoListOption) -> Void)?
    
    var didSelectGroupType: ((TodoGroupType) -> Void)?
    
    var didSelectSortType: ((TodoSortType) -> Void)?
    
    var didSelectSortOrder: ((TodoSortOrder) -> Void)?
    
    /// 列表选项
    var options: [TodoListOption]
    
    init(options: [TodoListOption]) {
        self.options = options
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
        return options
    }
    
    override func updateMenuAction(_ action: TPMenuAction, for type: TodoListOption) {
        action.handler = { _ in
            self.didSelectListOption?(type)
        }
        
        switch type {
        case .showCompleted:
            action.isChecked = true
        case .layout:
            action.subtitle = ""
        case .group:
            updateGroupAction(action)
        case .sort:
            updateSortAction(action)
        default:
            break
        }
    }
    
    private func updateGroupAction(_ action: TPMenuAction) {
        let groupType = TodoGroupType.priority
        let controller = TodoGroupTypeMenuController(types: TodoGroupType.allCases)
        controller.didSelectGroupType = self.didSelectGroupType
        action.subMenuItems = controller.menuItems()
        action.subtitle = groupType.title
    }
    
    private func updateSortAction(_ action: TPMenuAction) {
        let sort = TodoSort()
        let sortTypeMenuItem = sortTypeMenuItem(sortType: sort.type)
        let sortOrderMenuItem = sortOrderMenuItem(sortOrder: sort.order)
        action.subMenuItems = [sortTypeMenuItem, sortOrderMenuItem]
        action.subtitle = "\(sort.type.title)•\(sort.order.title)"
    }
    
    private func sortTypeMenuItem(sortType: TodoSortType) -> TPMenuItem {
        let allowSortTypes = TodoSortType.allCases
        let menuItem = TPMenuItem.item(with: allowSortTypes) { type, action in
            action.handleBeforeDismiss = true
            action.isChecked = type == sortType
            action.handler = { _ in
                self.didSelectSortType?(type)
            }
        }
        
        return menuItem
    }
    
    private func sortOrderMenuItem(sortOrder: TodoSortOrder) -> TPMenuItem {
        let menuItem = TPMenuItem.item(with: TodoSortOrder.allCases) { order, action in
            action.handleBeforeDismiss = true
            action.isChecked = order == sortOrder
            action.handler = { _ in
                self.didSelectSortOrder?(order)
            }
        }
        
        return menuItem
    }
}


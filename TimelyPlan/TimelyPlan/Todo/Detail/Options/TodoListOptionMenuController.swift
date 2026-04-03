//
//  TodoListOptionMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/25.
//

import Foundation
import CoreText

class TodoListOptionMenuController: TPBaseMenuController<TodoListOption> {

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
                 [.edit, .delete],
                 [.emptyTrash]]
        return lists
    }
    
    override func menuActionTypes() -> [TodoListOption] {
        return options
    }
    
    override func updateMenuAction(_ action: TPMenuAction, for type: TodoListOption) {
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
        let menuItem = TPMenuItem.item(with: allowSortTypes) { [weak self] type, action in
            action.isChecked = type == sortType
            action.handler = { [weak self] _ in
                
            }
        }
        
        return menuItem
    }
    
    private func sortOrderMenuItem(sortOrder: TodoSortOrder) -> TPMenuItem {
        let menuItem = TPMenuItem.item(with: TodoSortOrder.allCases) { [weak self]  order, action in
            action.isChecked = order == sortOrder
            action.handler = { [weak self] _ in
                
            }
        }
        
        return menuItem
    }
}


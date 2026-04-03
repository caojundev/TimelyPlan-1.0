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
    
    /// 配置
    var configuration: TodoListConfiguration
    
    init(options: [TodoListOption], configuration: TodoListConfiguration) {
        self.options = options
        self.configuration = configuration
        super.init()
        self.menuContentWidth = 240.0
    }
    
    override func orderedMenuActionTypeLists() -> [Array<TodoListOption>] {
        var lists: [Array<TodoListOption>]
        lists = [[.select, .showCompleted],
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
            action.isChecked = configuration.showCompleted
        case .layout:
            action.subtitle = configuration.layoutType.title
        case .group:
            action.subtitle = configuration.groupType.title
        case .sort:
            action.subtitle = "\(configuration.sortType.title)•\(configuration.sortOrder.title)"
        default:
            break
        }
    }
}


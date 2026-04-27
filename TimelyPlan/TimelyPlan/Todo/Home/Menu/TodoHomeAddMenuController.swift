//
//  TodoHomeAddMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/22.
//

import Foundation

enum TodoHomeAddType: String, TPMenuRepresentable {
    case list
    case tag
    case filter
    
    var iconName: String? {
        switch self {
        case .list:
            return "todo_home_list_24"
        case .tag:
            return "todo_home_tag_24"
        case .filter:
            return "todo_home_filter_24"
        }
    }
}


class TodoHomeAddMenuController: TPBaseMenuController<TodoHomeAddType> {
  
    override func orderedMenuActionTypeLists() -> [Array<TodoHomeAddType>] {
        return [[.list], [.tag, .filter]]
    }
    
    override func menuActionTypes() -> [TodoHomeAddType] {
        return TodoHomeAddType.allCases
    }
}


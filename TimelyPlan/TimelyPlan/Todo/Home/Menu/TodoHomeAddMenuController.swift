//
//  TodoHomeAddMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/22.
//

import Foundation

enum TodoHomeAddType: Int, TPMenuRepresentable {
    case list
    case tag
    case filter
    
    var title: String {
        switch self {
        case .list:
            return resGetString("Add List")
        case .tag:
            return resGetString("Add Tag")
        case .filter:
            return resGetString("Add Filter")
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


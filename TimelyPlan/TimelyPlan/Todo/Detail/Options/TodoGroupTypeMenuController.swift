//
//  TodoGroupTypeMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/26.
//

import Foundation

class TodoGroupTypeMenuController: TPBaseMenuController<TodoGroupType> {
    
    var types: [TodoGroupType]
    
    init(types: [TodoGroupType]) {
        self.types = types
        super.init()
        self.menuContentWidth = 220.0
    }

    override func orderedMenuActionTypeLists() -> [Array<TodoGroupType>] {
        var lists: [Array<TodoGroupType>]
        lists = [[.default, .list, .startDate, .dueDate, .priority],
                 [.none]]
        return lists
    }
    
    override func menuActionTypes() -> [TodoGroupType] {
        return types
    }
}


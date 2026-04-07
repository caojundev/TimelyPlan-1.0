//
//  TodoGroupTypeMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/26.
//

import Foundation

class TodoGroupTypeMenuController: TPBaseMenuController<TodoGroupType> {
    
    var didSelectGroupType: ((TodoGroupType) -> Void)?
    
    var types: [TodoGroupType]
    
    init(types: [TodoGroupType]) {
        self.types = types
        super.init()
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
    
    override func updateMenuAction(_ action: TPMenuAction, for type: TodoGroupType) {
        action.handler = { _ in
            self.didSelectGroupType?(type)
        }
    }
}


//
//  MyDayEventAddType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/27.
//

import Foundation

enum MyDayEventAddType: Int, TPMenuRepresentable {
    case bind
    case todo
    case habit
    case focus
    
    var title: String {
        switch self {
        case .bind:
            return resGetString("Bind Task")
        case .todo:
            return resGetString("Add Todo")
        case .habit:
            return resGetString("Add Habit")
        case .focus:
            return resGetString("Add Focus")
        }
    }
    
    var iconName: String? {
        switch self {
        case .bind:
            return "bind_24"
        case .todo:
            return "myDayEventAdd_todo_24"
        case .habit:
            return "myDayEventAdd_habit_24"
        case .focus:
            return "myDayEventAdd_focus_24"
        }
    }
}


class MyDayEventAddMenuController: TPBaseMenuController<MyDayEventAddType> {
  
    override func orderedMenuActionTypeLists() -> [Array<MyDayEventAddType>] {
        return [[.bind], [.todo, .habit, .focus]]
    }
    
    override func menuActionTypes() -> [MyDayEventAddType] {
        return MyDayEventAddType.allCases
    }
}


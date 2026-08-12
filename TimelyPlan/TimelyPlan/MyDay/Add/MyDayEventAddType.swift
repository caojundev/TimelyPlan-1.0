//
//  MyDayEventAddType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/27.
//

import Foundation

enum MyDayEventAddType: Int, TPMenuRepresentable {
    case bind
    case calendar
    case todo
    case habit
    case focus
    
    var title: String {
        switch self {
        case .bind:
            return resGetString("Bind Event")
        case .calendar:
            return resGetString("Calendar Event")
        case .todo:
            return resGetString("Todo Task")
        case .habit:
            return resGetString("Habit Task")
        case .focus:
            return resGetString("Focus Timer")
        }
    }
    
    var iconName: String? {
        switch self {
        case .bind:
            return "bind_24"
        case .calendar:
            return "calendar_24"
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
  
    let addTypes: [MyDayEventAddType]
    
    init(addTypes: [MyDayEventAddType] = MyDayEventAddType.allCases) {
        self.addTypes = addTypes
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<MyDayEventAddType>] {
        return [[.bind], [.calendar], [.todo, .habit], [.focus]]
    }
    
    override func menuActionTypes() -> [MyDayEventAddType] {
        return addTypes
    }
}


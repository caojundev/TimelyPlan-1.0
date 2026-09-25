//
//  EventAddType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/27.
//

import Foundation

enum EventAddType: Int, TPMenuRepresentable {
    case bind
    case calendar
    case todo
    case habit
    case focus
    case goal
    case countdown
    
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
        case .goal:
            return resGetString("Goal Task")
        case .countdown:
            return resGetString("Countdown")
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
        case .goal:
            return "goal_24"
        case .countdown:
            return "goal_24"
        }
    }
    
    static var allExceptBind: [EventAddType] {
        var types = EventAddType.allCases
        types.remove(.bind)
        return types
    }
}

class MyDayEventAddMenuController: TPBaseMenuController<EventAddType> {
  
    let addTypes: [EventAddType]
    
    init(addTypes: [EventAddType] = EventAddType.allCases) {
        self.addTypes = addTypes
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<EventAddType>] {
        return [[.bind],
                [.calendar],
                [.todo, .goal, .habit],
                [.focus],
                [.countdown]]
    }
    
    override func menuActionTypes() -> [EventAddType] {
        return addTypes
    }
}


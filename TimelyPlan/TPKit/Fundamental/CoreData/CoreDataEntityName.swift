//
//  CoreDataEntityName.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/18.
//

import Foundation

enum EntityName: String, CaseIterable {
    case todoList = "CDTodoList"
    case todoSection = "CDTodoSection"
    case todoTask = "CDTodoTask"
    case todoTag = "CDTodoTag"
    case todoFilter = "CDTodoFilter"
    case focusSession = "CDFocusSession"
    case focusTimer = "CDFocusTimer"
    case habitRecord = "CDHabitRecord"
    case habitSample = "CDHabitSample"
    case habitTask = "CDHabitTask"
    case keyValueStore = "KeyValueStore"
}

// MARK: - 扩展：分组
extension EntityName {
    enum Group {
        case focus, habit, todo, storage
        
        var entities: Set<EntityName> {
            switch self {
            case .focus:  return [.focusSession, .focusTimer]
            case .habit:  return [.habitRecord, .habitSample, .habitTask]
            case .todo:   return [.todoFilter, .todoList, .todoSection, .todoTag, .todoTask]
            case .storage: return [.keyValueStore]
            }
        }
    }
}

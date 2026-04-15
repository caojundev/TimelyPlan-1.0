//
//  TodoState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/15.
//

import Foundation

class TodoState {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case listOption  /// 列表选项
        
        static func keyPrefix() -> String? {
            return "TodoState"
        }
    }

    @LocalStored(key: SettingKey.listOption.name, defaultValue: nil)
    private var listOptionStates: [String: TodoListOptionState]?
    
    func setListOptionSate(_ state: TodoListOptionState, for item: IdentifiableItem) {
        var states = listOptionStates ?? [:]
        states[item.identifier] = state
        listOptionStates = states
    }

    func listOptionState(for item: IdentifiableItem) -> TodoListOptionState? {
        return listOptionStates?[item.identifier]
    }
    
    static let shared = TodoState()
    
    private init() {}
}

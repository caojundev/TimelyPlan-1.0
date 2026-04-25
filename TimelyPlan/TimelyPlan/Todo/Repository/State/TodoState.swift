//
//  TodoState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/15.
//

import Foundation

class TodoState {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case collapsedListStates
        case isHomeListExpanded /// 列表是否展开
        case isHomeTagExpanded  /// 标签是否展开
        case isHomeFilterExpanded /// 过滤器是否展开
        
        case listOption  /// 列表选项
        
        static func keyPrefix() -> String? {
            return "TodoState"
        }
    }
    
    @LocalStored(key: SettingKey.collapsedListStates.name, defaultValue: nil)
    var collapsedListStates: [String: Bool]?
    
    @LocalStored(key: SettingKey.listOption.name, defaultValue: nil)
    private var listOptionStates: [String: TodoListOptionState]?
    
    @LocalStored(key: SettingKey.isHomeListExpanded.name, defaultValue: true)
    var isHomeListExpanded: Bool
    
    @LocalStored(key: SettingKey.isHomeTagExpanded.name, defaultValue: true)
    var isHomeTagExpanded: Bool
    
    @LocalStored(key: SettingKey.isHomeFilterExpanded.name, defaultValue: true)
    var isHomeFilterExpanded: Bool

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

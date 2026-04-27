//
//  TodoState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/15.
//

import Foundation

class TodoState {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case collapsedListStates  /// 收起列表状态
        case collapsedGroupStates /// 收起分组状态
        case isHomeListExpanded   /// 列表是否展开
        case isHomeTagExpanded    /// 标签是否展开
        case isHomeFilterExpanded /// 过滤器是否展开
        
        case listOption  /// 列表选项
        
        static func keyPrefix() -> String? {
            return "TodoState"
        }
    }
    
    @LocalStored(key: SettingKey.collapsedListStates.name, defaultValue: nil)
    var collapsedListStates: [String: Bool]?
    
    @LocalStored(key: SettingKey.collapsedGroupStates.name, defaultValue: nil)
    private var collapsedGroupStates: [String: [String: Bool]]?
    
    @LocalStored(key: SettingKey.listOption.name, defaultValue: nil)
    private var listOptionStates: [String: TodoListOptionState]?
    
    @LocalStored(key: SettingKey.isHomeListExpanded.name, defaultValue: true)
    var isHomeListExpanded: Bool
    
    @LocalStored(key: SettingKey.isHomeTagExpanded.name, defaultValue: true)
    var isHomeTagExpanded: Bool
    
    @LocalStored(key: SettingKey.isHomeFilterExpanded.name, defaultValue: true)
    var isHomeFilterExpanded: Bool
    
    static let shared = TodoState()
    
    private init() {}
    
    // MARK: - 列表选项状态
    func listOptionState(for item: IdentifiableItem) -> TodoListOptionState? {
        return listOptionStates?[item.identifier]
    }
    
    func setListOptionSate(_ state: TodoListOptionState, for item: IdentifiableItem) {
        var states = listOptionStates ?? [:]
        states[item.identifier] = state
        self.listOptionStates = states
    }
    
    // MARK: - 分组状态
    func groupStates(for identifier: String) -> [String: Bool]? {
        return collapsedGroupStates?[identifier]
    }
    
    func setGroupStates(_ states: [String: Bool]?, for identifier: String) {
        var collapsedGroupStates = collapsedGroupStates ?? [:]
        collapsedGroupStates[identifier] = states
        self.collapsedGroupStates = collapsedGroupStates
    }
    
}

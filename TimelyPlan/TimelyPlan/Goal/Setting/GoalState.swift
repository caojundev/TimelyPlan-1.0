//
//  GoalState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation

class GoalState {
    
    enum Key: String, SettingKeyRepresentable {
        case planOptionStates  /// 计划选项
        case collapsedGroupStates /// 收起分组状态
        
        static func keyPrefix() -> String? {
            return "GoalState"
        }
    }

    @LocalStored(key: Key.planOptionStates.name, defaultValue: nil)
    private var planOptionStates: [String: GoalPlanOptionState]?

    @LocalStored(key: Key.collapsedGroupStates.name, defaultValue: nil)
    private var collapsedGroupStates: [String: [String: Bool]]?
    
    static let shared = GoalState()
    
    private init() {}
    
    // MARK: - 列表选项状态
    func planOptionState(for item: IdentifiableItem) -> GoalPlanOptionState? {
        return planOptionStates?[item.identifier]
    }
    
    func setPlanOptionSate(_ state: GoalPlanOptionState, for item: IdentifiableItem) {
        var states = planOptionStates ?? [:]
        states[item.identifier] = state
        self.planOptionStates = states
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

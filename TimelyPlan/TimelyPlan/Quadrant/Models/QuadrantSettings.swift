//
//  QuadrantSettings.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/20.
//

import Foundation

enum QuadrantSettingKey: String, SettingKeyRepresentable {
    
    case showCompleted
    
    case showDetail

    case layout
    
    case customRules
    
    static func keyPrefix() -> String? {
        return "Quadrant"
    }
}

class QuadrantSettingAgent: SettingAgentObserver {

    var didChangeSettingValue: ((QuadrantSettingKey) -> Void)?
    
    var showCompleted: Bool {
        get {
            return value(forKey: .showCompleted) ?? true
        }
        
        set {
            if newValue != showCompleted {
                setValue(newValue, forKey: .showCompleted)
            }
        }
    }
    
    var showDetail: Bool {
        get {
            return value(forKey: .showDetail) ?? true
        }
        
        set {
            if newValue != showDetail {
                setValue(newValue, forKey: .showDetail)
            }
        }
    }
    
    var layout: QuadrantLayout {
        get {
            return value(forKey: .layout) { QuadrantLayout() }
        }
        
        set {
            if newValue != layout {
                setValue(newValue, forKey: .layout)
            }
        }
    }
    
    /// 自定义规则
    var customRules: [Quadrant: TodoFilterRule] {
        get {
            return value(forKey: .customRules) {
                TodoFilterRule.defaultQuadrantFilterRules
            }
        }
        
        set {
            if newValue != customRules {
                setValue(newValue, forKey: .customRules)
            }
        }
    }
    
    static let shared = QuadrantSettingAgent()
    
    private init() {
        SettingAgent.shared.addObserver(self, forKeys: QuadrantSettingKey.allNames)
    }
    
    func filterRule(for quadrant: Quadrant) -> TodoFilterRule {
        let filterRule = customRules[quadrant] ?? .defaultFilterRule(for: quadrant)
        return filterRule
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for key: String) {
        if let QuadrantSettingKey = QuadrantSettingKey(name: key) {
            didChangeSettingValue?(QuadrantSettingKey)
        }
    }
    
    // MARK: - Helpers
    func value<T: Codable>(forKey key: QuadrantSettingKey, defaultValue: () -> T) -> T {
        return SettingAgent.shared.value(forKey: key.name, defaultValue: defaultValue)
    }
    
    private func value<T: Codable>(forKey key: QuadrantSettingKey) -> T? {
        return SettingAgent.shared.value(forKey: key.name)
    }
    
    private func setValue(_ value: Codable?, forKey key: QuadrantSettingKey) {
        SettingAgent.shared.setValue(value, forKey: key.name)
    }
}

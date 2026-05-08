//
//  QuadrantSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/20.
//

import Foundation

class QuadrantSetting {
    
    enum Key: String, SettingKeyRepresentable {
        case showCompleted
        case showDetail
        case layout
        case customRules
        
        static func keyPrefix() -> String? {
            return "QuadrantSetting"
        }
    }

    @CloudStored(key: Key.showCompleted.name, defaultValue: false)
    var showCompleted: Bool
    
    @CloudStored(key: Key.showDetail.name, defaultValue: false)
    var showDetail: Bool
    
    @CloudStored(key: Key.layout.name, defaultValue: QuadrantLayout())
    var layout: QuadrantLayout

    @CloudStored(key: Key.customRules.name, defaultValue: TodoFilterRule.defaultQuadrantFilterRules)
    var customRules: [Quadrant: TodoFilterRule]
    
    static let shared = QuadrantSetting()
    
    private init() {}
    
    func filterRule(for quadrant: Quadrant) -> TodoFilterRule {
        let filterRule = customRules[quadrant] ?? .defaultFilterRule(for: quadrant)
        return filterRule
    }
    
    func setFilterRule(_ filterRule: TodoFilterRule, for quadrant: Quadrant) {
        var rules = self.customRules
        rules[quadrant] = filterRule
        self.customRules = rules
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key? = nil) {
        KeyValueStorage.shared.addObserver(observer, forKey: key?.name)
    }
}

//
//  TodoFilterRule+Quadrant.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/6.
//

import Foundation

// MARK: - 默认过滤规则
extension TodoFilterRule {
    
    /// 返回象限的默认的过滤规则
    static func defaultFilterRule(for quadrant: Quadrant) -> TodoFilterRule {
        let priority: TodoTaskPriority
        switch quadrant {
        case .urgentImportant:
            priority = .high
        case .notUrgentImportant:
            priority = .medium
        case .urgentNotImportant:
            priority = .low
        case .notUrgentNotImportant:
            priority = .none
        }
        
        let rule = TodoFilterRule()
        rule.priorityFilterValue = TodoPriorityFilterValue(priorities: [priority])
        return rule
    }
    
    static var defaultQuadrantFilterRules: [Quadrant: TodoFilterRule] {
        var rules: [Quadrant: TodoFilterRule] = [:]
        for quadrant in Quadrant.allCases {
            rules[quadrant] = defaultFilterRule(for: quadrant)
        }
        
        return rules
    }
}

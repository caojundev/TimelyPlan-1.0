//
//  TodoEditingFilter.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation

struct TodoEditingFilter: Equatable {
    
    /// 名称
    var name: String?
    
    /// 颜色
    var color: UIColor = TodoFilter.defaultColor
    
    /// 规则
    var rule: TodoFilterRule?
    
    // MARK: - Equatable
    static func == (lhs: TodoEditingFilter, rhs: TodoEditingFilter) -> Bool {
        return lhs.name == rhs.name &&
                lhs.color.hexString == rhs.color.hexString &&
                lhs.rule == rhs.rule
    }
}

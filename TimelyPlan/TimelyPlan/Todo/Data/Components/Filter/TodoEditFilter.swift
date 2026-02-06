//
//  TodoEditFilter.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation

struct TodoEditFilter: Equatable {
    
    /// 名称
    var name: String?
    
    /// 颜色
    var color: UIColor = TodoFilter.defaultColor
    
    /// 规则
    var rule: TodoFilterRule?
    
    // MARK: - Equatable
    static func == (lhs: TodoEditFilter, rhs: TodoEditFilter) -> Bool {
        return lhs.name == rhs.name &&
                lhs.color.hexString == rhs.color.hexString &&
                lhs.rule == rhs.rule
    }
}

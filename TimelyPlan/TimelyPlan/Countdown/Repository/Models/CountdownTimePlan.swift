//
//  CountdownTimePlan.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/16.
//

import Foundation

/// 重复类型
enum CountdownTimePlanType: String, Codable, TPMenuRepresentable {
    case none    /// 不重复
    case daily   /// 每天
    case weekly  /// 每周
    case monthly /// 每周
    case yearly  /// 每年
    case custom  /// 自定义
    
    var title: String {
        return resGetString(rawValue.capitalized)
    }
    
    var regularRule: TaskTimePlanRegularRule? {
        switch self {
        case .daily:
            return TaskTimePlanRegularRule(frequency: .daily)
        case .weekly:
            return TaskTimePlanRegularRule(frequency: .weekly)
        case .monthly:
            return TaskTimePlanRegularRule(frequency: .monthly)
        case .yearly:
            return TaskTimePlanRegularRule(frequency: .yearly)
        default:
            return nil
        }
    }
}

/// 重复规则
struct CountdownTimePlan: Codable, Equatable {
    
    /// 类型
    var type: CountdownTimePlanType?
    
    /// 重复规则
    var recurrenceRule: TaskTimePlanRegularRule?
    
    init(type: CountdownTimePlanType, recurrenceRule: TaskTimePlanRegularRule? = nil) {
        self.type = type
        self.recurrenceRule = recurrenceRule
    }
    
    var descriptionTitle: String? {
        guard let type = type else {
            return nil
        }
        
        if type != .custom {
            return type.title
        }
        
        /// 自定义规则
        if let rule = recurrenceRule {
            return rule.title
        }
        
        return nil
    }
}

//
//  PredicateCondition.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/18.
//

import Foundation

// MARK: - 谓词比较类型枚举

/// 定义各种谓词比较操作的类型
/// 支持标准比较、集合操作、字符串匹配等多种谓词条件
enum PredicateComparison {
    // MARK: 基本比较操作
    case equal(_ value: Any)              /// 相等比较
    case notEqual(_ value: Any)           /// 不等比较
    case anyEqual(_ value: Any)           /// 集合中任意元素相等
    
    // MARK: 大小比较操作
    case greaterThan(_ value: Any)        /// 大于
    case greaterThanOrEqual(_ value: Any) /// 大于等于
    case lessThan(_ value: Any)           /// 小于
    case lessThanOrEqual(_ value: Any)    /// 小于等于
    case between(_ lower: Any, _ upper: Any) /// 区间比较
    
    // MARK: 集合操作
    case belongsTo(_ values: [Any])       /// IN 操作：在集合中
    case anyBelongsTo(_ values: [Any])    /// ANY 集合中任意匹配
    case notBelongsTo(_ values: [Any])    /// NOT IN 操作：不在集合中
    
    // MARK: 特殊操作
    case contains(_ string: String)       /// 字符串包含（不区分大小写）
    case isTrue                           /// 布尔真值
    case isFalse                          /// 布尔假值
    case isEmpty                          /// 空值判断
    case isNotEmpty                       /// 非空值判断
    
    /// 获取比较操作的符号字符串
    /// 用于构建 NSPredicate 的格式化字符串
    /// - Returns: 操作符号字符串，对于特殊操作返回 nil
    func operatorString() -> String? {
        switch self {
        case .equal:
            return "=="
        case .notEqual:
            return "!="
        case .greaterThanOrEqual:
            return ">="
        case .lessThanOrEqual:
            return "<="
        case .greaterThan:
            return ">"
        case .lessThan:
            return "<"
        case .belongsTo:
            return "IN"
        default:
            return nil
        }
    }
}

// MARK: - 类型别名

/// 谓词条件类型：由属性名和比较操作组成
typealias PredicateCondition = (attribute: String, comparison: PredicateComparison)

// MARK: - 谓词条件数组扩展

extension Array where Element == PredicateCondition {
    
    /// 将谓词条件数组转换为 NSPredicate 数组
    /// 遍历每个条件，生成对应的 NSPredicate 实例
    var predicates: [NSPredicate] {
        var predicates: [NSPredicate] = []
        for condition in self {
            let predicate = NSPredicate.predicate(with: condition)
            predicates.append(predicate)
        }
        return predicates
    }
    
    /// 创建 AND 逻辑组合谓词
    /// 所有条件都满足时才为真
    /// - Returns: AND 类型的 NSCompoundPredicate
    func andPredicate() -> NSCompoundPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    /// 创建 OR 逻辑组合谓词
    /// 任一条件满足时为真
    /// - Returns: OR 类型的 NSCompoundPredicate
    func orPredicate() -> NSCompoundPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
}

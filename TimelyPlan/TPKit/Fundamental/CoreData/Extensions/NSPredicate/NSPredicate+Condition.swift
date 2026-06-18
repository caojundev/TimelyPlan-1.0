//
//  NSPredicate+Condition.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/13.
//

import Foundation

extension NSPredicate {
    
    /// 创建 AND 与 OR 组合的复合谓词
    /// 内部使用 AND 连接 andConditions，然后与外层的 OR 连接
    /// - Parameters:
    ///   - andConditions: 需要同时满足的条件组
    ///   - orConditions: 满足其一即可的条件组
    /// - Returns: 组合后的复合谓词
    static func andPredicate(andConditions: [PredicateCondition],
                             orConditions: [PredicateCondition]) -> NSPredicate {
        let andPredicate = andConditions.andPredicate()
        let orPredicate = orConditions.orPredicate()
        return NSCompoundPredicate(andPredicateWithSubpredicates: [andPredicate, orPredicate])
    }
    
    /// 根据单个谓词条件创建 NSPredicate
    /// - Parameter condition: 包含属性名和比较操作的谓词条件
    /// - Returns: 生成的 NSPredicate 实例
    static func predicate(with condition: PredicateCondition) -> NSPredicate {
        let attribute = condition.attribute
        let comparison = condition.comparison
        
        let format: String
        var arguments: [Any]? = nil
        
        // 根据不同的比较类型构建对应的格式化字符串和参数
        switch comparison {
        // MARK: 标准比较操作
        case .equal(let value),
             .notEqual(let value),
             .greaterThan(let value),
             .greaterThanOrEqual(let value),
             .lessThan(let value),
             .lessThanOrEqual(let value):
            format = "\(attribute) \(comparison.operatorString()!) %@"
            arguments = [value]
            
        // MARK: 集合操作
        case .anyEqual(let value):
            format = "ANY \(attribute) == %@"
            arguments = [value]
            
        case .belongsTo(let values):
            format = "\(attribute) IN %@"
            arguments = [values]
            
        case .notBelongsTo(let values):
            format = "NOT (\(attribute) IN %@)"
            arguments = [values]
            
        case .anyBelongsTo(let values):
            format = "ANY \(attribute) IN %@"
            arguments = [values]
            
        // MARK: 范围操作
        case .between(let lower, let upper):
            format = "\(attribute) >= %@ AND \(attribute) <= %@"
            arguments = [lower, upper]
            
        // MARK: 字符串操作
        case .contains(let string):
            format = "\(attribute) CONTAINS[c] %@"
            arguments = [string]
            
        // MARK: 布尔和空值检查
        case .isTrue:
            format = "\(attribute) == true"
            
        case .isFalse:
            format = "\(attribute) == false"
            
        case .isEmpty:
            format = "\(attribute) == nil"
            
        case .isNotEmpty:
            format = "\(attribute) != nil"
        }
        
        return NSPredicate(format: format, argumentArray: arguments)
    }
}

//
//  NSPredicate+Condition.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/13.
//

import Foundation

enum PredicateComparison {
    case equal(_ value: Any)
    case notEqual(_ value: Any)
    case anyEqual(_ value: Any)
    
    case greaterThan(_ value: Any)
    case greaterThanOrEqual(_ value: Any)
    case lessThan(_ value: Any)
    case lessThanOrEqual(_ value: Any)
    case between(_ lower: Any, _ upper: Any)
    
    case belongsTo(_ values: [Any])  /// IN
    case anyBelongsTo(_ values: [Any])
    
    case contains(_ string: String)
    
    case isTrue
    case isFalse
    case isEmpty
    case isNotEmpty
    
    /// 操作符号
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

/// 谓词条件
typealias PredicateCondition = (attribute: String, comparison: PredicateComparison)

extension Array where Element == PredicateCondition {
   
    var predicates: [NSPredicate] {
        var predicates: [NSPredicate] = []
        for condition in self {
            let predicate = NSPredicate.predicate(with: condition)
            predicates.append(predicate)
        }
        
        return predicates
    }
    
    func andPredicate() -> NSCompoundPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    func orPredicate() -> NSCompoundPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
}

extension NSPredicate {
    
    static func andPredicate(andConditions: [PredicateCondition],
                             orConditions: [PredicateCondition]) -> NSPredicate {
        let andPredicate = andConditions.andPredicate()
        let orPredicate = orConditions.orPredicate()
        return NSCompoundPredicate(andPredicateWithSubpredicates: [andPredicate,
                                                                   orPredicate])
    }
    
    static func predicate(with condition: PredicateCondition) -> NSPredicate {
        let attribute = condition.attribute
        let comparison = condition.comparison
        
        let format: String
        var arguments: [Any]? = nil
        switch comparison {
        case .equal(let value),
                .notEqual(let value),
                .greaterThan(let value),
                .greaterThanOrEqual(let value),
                .lessThan(let value),
                .lessThanOrEqual(let value):
            format = "\(attribute) \(comparison.operatorString()!) %@"
            arguments = [value]
        case .anyEqual(let value):
            format = "ANY \(attribute) == %@"
            arguments = [value]
        case .between(let lower, let upper):
            format = "\(attribute) >= %@ AND \(attribute) <= %@"
            arguments = [lower, upper]
        case .belongsTo(let values):
            format = "\(attribute) IN %@"
            arguments = [values]
        case .anyBelongsTo(let values):
            format = "ANY \(attribute) IN %@"
            arguments = [values]
        case .contains(let string):
            format = "\(attribute) CONTAINS[c] %@"
            arguments = [string]
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

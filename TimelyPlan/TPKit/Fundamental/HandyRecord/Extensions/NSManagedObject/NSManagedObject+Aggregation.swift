//
//  NSManagedObject+Aggregation.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/12.
//

import Foundation
import CoreData

/// 聚合表达式函数
enum AggregationFunction: String {
    case sum = "sum:" /// 求和
}

extension NSManagedObject {
    
    // 获取当前托管对象所有条目数
    static func countOfEntries(in context: NSManagedObjectContext) -> Int {
        return countOfEntries(with: nil, in: context)
    }

    // 获取符合指定predicate的托管对象条目数
    static func countOfEntries(with predicate: NSPredicate?,
                               in context: NSManagedObjectContext) -> Int {
        let request = fetchAllRequest(in: context)
        request.predicate = predicate
        var count: Int = 0
        do {
            count = try context.count(for: request)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return count
    }

    // 当前托管对象是否至少存在一个条目
    static func hasAtLeastOneEntry(in context: NSManagedObjectContext) -> Bool {
        return countOfEntries(in: context) > 0
    }

    // 返回指定属性的最小值
    static func minimumValue(for attribute: String, in context: NSManagedObjectContext) -> Any? {
        let object = objectWithMinimumValue(for: attribute, in: context)
        return object?.value(forKey: attribute)
    }

    // 返回指定属性的最大值
    static func maximumValue(for attribute: String, in context: NSManagedObjectContext) -> Any? {
        let object = findFirst(where: attribute, isEqualTo: "max(\(attribute)", in: context)
        return object?.value(forKey: attribute)
    }

    // 返回具有最小属性值的托管对象
    static func objectWithMinimumValue(for attribute: String,
                                       in context: NSManagedObjectContext) -> Self? {
        let object = findFirst(where: attribute, isEqualTo: "min(\(attribute)", in: context)
        return object
    }

    // 返回具有最大属性值的托管对象
    static func objectWithMaximumValue(for attribute: String,
                                       in context: NSManagedObjectContext) -> Self? {
        let object = findFirst(where: attribute, isEqualTo: "max(\(attribute)", in: context)
        return object
    }
    
    /**
     *  支持使用键值集合操作符对实体属性进行聚合计算，并可以按指定属性进行分组。
     *  @param function             集合操作符字符串
     *  @param attribute            应用集合操作符的属性名
     *  @param predicate            过滤结果的谓词
     *  @param context              执行请求的上下文
     *
     *  @return 经过集合操作符计算后的结果，并符合谓词的过滤条件
     */
    static let AggregateResultName = "result"
    static func performAggregateOperation(function: AggregationFunction,
                                          onAttribute attribute: String,
                                          withPredicate predicate: NSPredicate?,
                                          in context: NSManagedObjectContext) -> Any? {
        let expressionDescription = expressionDescription(function: function,
                                                          onAttribute: attribute,
                                                          in: context)
        let request = fetchAllRequest(with: predicate, in: context)
        request.propertiesToFetch = [expressionDescription]
        request.resultType = .dictionaryResultType
        if let result = executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? [String: Any] {
            return result[AggregateResultName]
        }
    
        return nil
    }

    /**
     *  支持使用键值集合操作符对实体属性进行聚合计算，并可以按指定属性进行分组。
     *  @param collectionOperator   集合操作符字符串
     *  @param attribute            应用集合操作符的属性名
     *  @param predicate            过滤结果的谓词
     *  @param groupingKeyPath      按该键路径进行分组
     *  @param context              执行请求的上下文
     *
     *  @return 经过集合操作符计算后的结果，根据提供的键路径进行分组，并符合谓词的过滤条件
     */
    static func performAggregateOperation(function: AggregationFunction,
                                          onAttribute attribute: String,
                                          withPredicate predicate: NSPredicate?,
                                          groupBy groupingKeyPath: String,
                                          in context: NSManagedObjectContext) -> [Any]? {
        let expressionDescription = expressionDescription(function: function,
                                                          onAttribute: attribute,
                                                          in: context)
        let request = fetchAllRequest(with: predicate, in: context)
        request.propertiesToFetch = [groupingKeyPath, expressionDescription]
        request.resultType = .dictionaryResultType
        request.propertiesToGroupBy = [groupingKeyPath]
        return executeFetchRequest(request, in: context)
    }
    
    /// 获取表达式描述
    private static func expressionDescription(function: AggregationFunction,
                                              onAttribute attribute: String,
                                              in context: NSManagedObjectContext) -> NSExpressionDescription {
        let expression = NSExpression(forFunction: function.rawValue,
                                      arguments: [NSExpression(forKeyPath: attribute)])
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = AggregateResultName
        expressionDescription.expression = expression
        
        /// 设置表达式结果类型
        let entityDescription = entityDescription(in: context)
        if let attributeDescription = entityDescription?.attributesByName[attribute] {
            expressionDescription.expressionResultType = attributeDescription.attributeType
        }
        
        return expressionDescription
    }
}

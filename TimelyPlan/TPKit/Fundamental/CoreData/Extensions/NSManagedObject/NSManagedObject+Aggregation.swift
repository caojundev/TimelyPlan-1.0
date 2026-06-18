//
//  NSManagedObject+Aggregation.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/12.
//

import Foundation
import CoreData

// MARK: - 聚合函数枚举

/// 支持的聚合函数类型
/// 用于对 Core Data 实体属性进行聚合计算
enum AggregationFunction: String {
    /// 求和操作
    case sum = "sum:"
    /// 最大值操作
    case max = "max:"
    /// 最小值操作
    case min = "min:"
}

// MARK: - NSManagedObject 聚合操作扩展

extension NSManagedObject {
    
    // MARK: 聚合结果常量
    
    /// 聚合操作返回结果的键名
    /// 用于从字典结果中提取聚合计算值
    static let AggregateResultName = "result"
    
    // MARK: 计数操作
    
    /// 获取指定上下文中当前实体的总条目数
    /// - Parameter context: 托管对象上下文
    /// - Returns: 实体条目总数，查询失败返回 0
    static func countOfEntries(in context: NSManagedObjectContext) -> Int {
        return countOfEntries(with: nil, in: context)
    }

    /// 获取符合谓词条件的实体条目数
    /// - Parameters:
    ///   - predicate: 过滤谓词，nil 表示不进行过滤
    ///   - context: 托管对象上下文
    /// - Returns: 符合条件的条目数，查询失败返回 0
    static func countOfEntries(with predicate: NSPredicate?,
                               in context: NSManagedObjectContext) -> Int {
        let request = fetchAllRequest(in: context)
        request.predicate = predicate
        
        do {
            return try context.count(for: request)
        } catch {
            debugPrint("计数查询失败: \(error.localizedDescription)")
            return 0
        }
    }

    /// 检查指定上下文中是否至少存在一个实体条目
    /// - Parameter context: 托管对象上下文
    /// - Returns: 是否存在至少一个条目
    static func hasAtLeastOneEntry(in context: NSManagedObjectContext) -> Bool {
        return countOfEntries(in: context) > 0
    }

    // MARK: 简单聚合操作

    /// 获取指定属性的最小值
    /// - Parameters:
    ///   - attribute: 属性名称
    ///   - context: 托管对象上下文
    /// - Returns: 属性最小值，查询失败返回 nil
    static func minimumValue(for attribute: String, in context: NSManagedObjectContext) -> Any? {
        return performAggregateOperation(function: .min,
                                         onAttribute: attribute,
                                         withPredicate: nil,
                                         in: context)
    }

    /// 获取指定属性的最大值
    /// - Parameters:
    ///   - attribute: 属性名称
    ///   - context: 托管对象上下文
    /// - Returns: 属性最大值，查询失败返回 nil
    static func maximumValue(for attribute: String, in context: NSManagedObjectContext) -> Any? {
        return performAggregateOperation(function: .max,
                                         onAttribute: attribute,
                                         withPredicate: nil,
                                         in: context)
    }

    // MARK: 聚合操作执行
    
    /// 执行聚合计算操作
    /// - Parameters:
    ///   - function: 聚合函数类型（sum、max、min）
    ///   - attribute: 应用聚合操作的属性名
    ///   - predicate: 过滤谓词，nil 表示对所有记录进行计算
    ///   - context: 执行查询的托管对象上下文
    /// - Returns: 聚合计算结果，查询失败返回 nil
    static func performAggregateOperation(function: AggregationFunction,
                                          onAttribute attribute: String,
                                          withPredicate predicate: NSPredicate?,
                                          in context: NSManagedObjectContext) -> Any? {
        let request = aggregateOperationFetchRequest(function: function,
                                                     onAttribute: attribute,
                                                     withPredicate: predicate,
                                                     in: context)
        
        // 执行查询并提取聚合结果
        if let result = executeFetchRequestAndReturnFirstObject(request: request,
                                                                inContext: context) as? [String: Any] {
            return result[AggregateResultName]
        }
    
        return nil
    }
    
    // MARK: 异步聚合操作
    
    /// 异步执行聚合计算操作
    /// - Parameters:
    ///   - function: 聚合函数类型
    ///   - attribute: 应用聚合操作的属性名
    ///   - predicate: 过滤谓词
    ///   - completion: 完成回调，在主线程中返回计算结果
    static func performAggregateOperation(function: AggregationFunction,
                                          onAttribute attribute: String,
                                          withPredicate predicate: NSPredicate?,
                                          completion: @escaping (Any?) -> Void) {
        let request = aggregateOperationFetchRequest(function: function,
                                                     onAttribute: attribute,
                                                     withPredicate: predicate,
                                                     in: .defaultContext)
        
        // 异步执行查询并在主线程返回结果
        self.executeFetchRequestAndReturnFirstObject(request: request) { result in
            var value: Any?
            if let resultDictionary = result as? [String: Any] {
                value = resultDictionary[AggregateResultName]
            }
            
            DispatchQueue.main.async {
                completion(value)
            }
        }
    }
    
    // MARK: 分组聚合操作
    
    /// 执行分组聚合计算操作
    /// 支持按指定属性进行分组后，对每组数据执行聚合计算
    /// - Parameters:
    ///   - function: 聚合函数类型
    ///   - attribute: 应用聚合操作的属性名
    ///   - predicate: 过滤谓词
    ///   - groupingKeyPath: 分组键路径
    ///   - context: 执行查询的托管对象上下文
    /// - Returns: 分组聚合结果数组，每个元素为包含分组键和聚合值的字典
    static func performAggregateOperation(function: AggregationFunction,
                                          onAttribute attribute: String,
                                          withPredicate predicate: NSPredicate?,
                                          groupBy groupingKeyPath: String,
                                          in context: NSManagedObjectContext) -> [Any]? {
        let expressionDescription = expressionDescription(function: function,
                                                          onAttribute: attribute,
                                                          in: context)
        
        // 配置分组查询请求
        let request = fetchAllRequest(with: predicate, in: context)
        request.propertiesToFetch = [groupingKeyPath, expressionDescription]
        request.resultType = .dictionaryResultType
        request.propertiesToGroupBy = [groupingKeyPath]
        
        return executeFetchRequest(request, in: context)
    }
    
    // MARK: 请求构建
    
    /// 构建聚合操作的查询请求
    /// - Parameters:
    ///   - function: 聚合函数类型
    ///   - attribute: 聚合属性名
    ///   - predicate: 过滤谓词
    ///   - context: 托管对象上下文
    /// - Returns: 配置好的聚合查询请求
    static func aggregateOperationFetchRequest(function: AggregationFunction,
                                               onAttribute attribute: String,
                                               withPredicate predicate: NSPredicate?,
                                               in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        // 创建表达式描述
        let expressionDescription = self.expressionDescription(function: function,
                                                               onAttribute: attribute,
                                                               in: context)
        
        // 配置查询请求
        let request = fetchAllRequest(with: predicate, in: context)
        request.propertiesToFetch = [expressionDescription]
        request.resultType = .dictionaryResultType
        
        return request
    }
    
    // MARK: 私有辅助方法
    
    /// 创建聚合表达式描述对象
    /// - Parameters:
    ///   - function: 聚合函数类型
    ///   - attribute: 聚合属性名
    ///   - context: 托管对象上下文（用于获取属性类型信息）
    /// - Returns: 表达式描述对象
    private static func expressionDescription(function: AggregationFunction,
                                              onAttribute attribute: String,
                                              in context: NSManagedObjectContext) -> NSExpressionDescription {
        // 创建聚合表达式
        let expression = NSExpression(forFunction: function.rawValue,
                                      arguments: [NSExpression(forKeyPath: attribute)])
        
        // 配置表达式描述
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = AggregateResultName
        expressionDescription.expression = expression
        
        // 设置表达式结果类型，确保与属性类型一致
        if let entityDescription = entityDescription(in: context),
           let attributeDescription = entityDescription.attributesByName[attribute] {
            expressionDescription.expressionResultType = attributeDescription.attributeType
        } else {
            debugPrint("警告：无法获取属性 '\(attribute)' 的类型信息")
        }
        
        return expressionDescription
    }
}

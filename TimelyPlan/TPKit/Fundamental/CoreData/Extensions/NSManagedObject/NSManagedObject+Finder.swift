//
//  NSManagedObject+Finder.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/12.
//

import Foundation
import CoreData
// MARK: - 同步查询操作

extension NSManagedObject {
    
    // MARK: 查询所有记录
    
    /// 查询当前实体的所有记录
    /// - Parameter context: 托管对象上下文
    /// - Returns: 实体记录数组，查询失败返回 nil
    static func getAll<T>(in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }

    /// 查询符合谓词条件的所有记录，支持多键排序
    /// - Parameters:
    ///   - predicate: 过滤谓词（可选）
    ///   - sortTerms: 排序条件数组
    ///   - context: 托管对象上下文
    /// - Returns: 符合条件的记录数组，查询失败返回 nil
    static func getAll<T>(matching predicate: NSPredicate?,
                          sortTerms: [SortTerm]?,
                          in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(with: predicate,
                                      sortTerms: sortTerms,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }

    /// 查询符合谓词条件的所有记录
    /// - Parameters:
    ///   - predicate: 过滤谓词
    ///   - context: 托管对象上下文
    /// - Returns: 符合条件的记录数组，查询失败返回 nil
    static func getAll<T>(matching predicate: NSPredicate,
                          in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(with: predicate, in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }
    
    /// 查询指定属性等于特定值的所有记录
    /// - Parameters:
    ///   - attribute: 属性名称
    ///   - value: 匹配值
    ///   - context: 托管对象上下文
    /// - Returns: 符合条件的记录数组，查询失败返回 nil
    static func getAll<T>(where attribute: String,
                          isEqualTo value: Any,
                          in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(where: attribute,
                                      isEqualTo: value,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }
    
    /// 查询指定属性等于特定值的所有记录，支持排序
    /// - Parameters:
    ///   - attribute: 属性名称
    ///   - value: 匹配值，nil 表示查询属性为空的记录
    ///   - key: 排序键
    ///   - ascending: 是否升序排列
    ///   - context: 托管对象上下文
    /// - Returns: 符合条件的记录数组，查询失败返回 nil
    static func getAll<T>(where attribute: String,
                          isEqualTo value: Any?,
                          sortBy key: String,
                          ascending: Bool,
                          in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        // 构建谓词：值存在则使用等值比较，否则查询空值
        let predicate: NSPredicate
        if let value = value {
            predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, value])
        } else {
            predicate = NSPredicate(format: "%K = nil", attribute)
        }
        
        let request = fetchAllRequest(with: predicate,
                                      sortBy: key,
                                      ascending: ascending,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }
    
    /// 查询所有记录，支持单键排序
    /// - Parameters:
    ///   - predicate: 过滤谓词（可选）
    ///   - key: 排序键
    ///   - ascending: 是否升序排列
    ///   - context: 托管对象上下文
    /// - Returns: 符合条件的记录数组，查询失败返回 nil
    static func getAll<T>(matching predicate: NSPredicate? = nil,
                          sortBy key: String,
                          ascending: Bool,
                          in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(with: predicate,
                                      sortBy: key,
                                      ascending: ascending,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }

    // MARK: 查询第一条记录
    
    /// 查询当前实体的第一条记录
    /// - Parameter context: 托管对象上下文
    /// - Returns: 第一条实体记录，无记录返回 nil
    static func getFirst(in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    /// 查询排序后的第一条记录
    /// - Parameters:
    ///   - key: 排序键
    ///   - ascending: 是否升序排列
    ///   - context: 托管对象上下文
    /// - Returns: 第一条符合条件的记录，无记录返回 nil
    static func getFirst(sortBy key: String,
                         ascending: Bool,
                         in context: NSManagedObjectContext) -> Self? {
        return getFirst(matching: nil, sortBy: key, ascending: ascending, in: context)
    }
    
    /// 查询指定属性等于特定值的第一条记录
    /// - Parameters:
    ///   - attribute: 属性名称
    ///   - value: 匹配值
    ///   - context: 托管对象上下文
    /// - Returns: 第一条匹配的记录，无匹配返回 nil
    static func getFirst(where attribute: String,
                         isEqualTo value: Any,
                         in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(where: attribute,
                                      isEqualTo: value,
                                      in: context)
        return executeFetchRequestAndReturnFirstObject(request: request,
                                                       inContext: context) as? Self
    }

    /// 查询或创建记录：查询指定属性匹配的第一条记录，如果不存在则创建新记录
    /// - Parameters:
    ///   - attribute: 属性名称
    ///   - value: 匹配值
    ///   - context: 托管对象上下文
    /// - Returns: 已存在的记录或新创建的记录
    static func getFirstOrCreate(where attribute: String,
                                 isEqualTo value: Any,
                                 in context: NSManagedObjectContext) -> Self {
        if let existingRecord = getFirst(where: attribute, isEqualTo: value, in: context) {
            return existingRecord
        }
        
        // 创建新记录并设置属性值
        let newRecord = Self.createEntity(in: context)
        newRecord.setValue(value, forKey: attribute)
        return newRecord
    }

    /// 查询符合谓词条件的第一条记录
    /// - Parameters:
    ///   - predicate: 过滤谓词（可选）
    ///   - context: 托管对象上下文
    /// - Returns: 第一条匹配的记录，无匹配返回 nil
    static func getFirst(matching predicate: NSPredicate?,
                         in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(with: predicate, in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    /// 查询符合谓词条件并排序后的第一条记录
    /// - Parameters:
    ///   - predicate: 过滤谓词（可选）
    ///   - key: 排序键
    ///   - ascending: 是否升序排列
    ///   - context: 托管对象上下文
    /// - Returns: 第一条匹配的记录，无匹配返回 nil
    static func getFirst(matching predicate: NSPredicate?,
                         sortBy key: String,
                         ascending: Bool,
                         in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(with: predicate,
                                      sortBy: key,
                                      ascending: ascending,
                                      in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    /// 查询符合谓词条件的第一条记录，仅获取指定属性
    /// - Parameters:
    ///   - predicate: 过滤谓词（可选）
    ///   - retrieveAttributes: 需要获取的属性名称数组
    ///   - context: 托管对象上下文
    /// - Returns: 第一条匹配的记录（仅包含指定属性），无匹配返回 nil
    static func getFirst(matching predicate: NSPredicate?,
                         retrieveAttributes: [String],
                         in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(in: context)
        request.predicate = predicate
        request.propertiesToFetch = properties(names: retrieveAttributes, in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    /// 查询符合谓词条件并排序后的第一条记录，仅获取指定属性
    /// - Parameters:
    ///   - predicate: 过滤谓词（可选）
    ///   - key: 排序键
    ///   - ascending: 是否升序排列
    ///   - retrieveAttributes: 需要获取的属性名称数组
    ///   - context: 托管对象上下文
    /// - Returns: 第一条匹配的记录（仅包含指定属性），无匹配返回 nil
    static func getFirst(matching predicate: NSPredicate?,
                         sortBy key: String,
                         ascending: Bool,
                         retrieveAttributes: [String],
                         in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(with: predicate,
                                      sortBy: key,
                                      ascending: ascending,
                                      in: context)
        request.propertiesToFetch = properties(names: retrieveAttributes, in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }
}


// MARK: - 异步获取
extension NSManagedObject {
    
    static func fetchFirst(matching predicate: NSPredicate?,
                           completion: @escaping(NSFetchRequestResult?) -> Void) {
        let request = fetchAllRequest(with: predicate, in: .defaultContext)
        executeFetchRequestAndReturnFirstObject(request: request, completion: completion)
    }
    
    static func fetchAll(completion:@escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }

    static func fetchAll(matching predicate: NSPredicate,
                         completion: @escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(with: predicate, in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }
    
    static func fetchAll(matching predicate: NSPredicate,
                         sortTerms: [SortTerm]?,
                         completion: @escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(with: predicate, sortTerms: sortTerms, in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }
    
    static func fetchAll(matching predicate: NSPredicate,
                         sortBy key: String,
                         ascending: Bool,
                         completion: @escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(with: predicate,
                                      sortBy: key,
                                      ascending: ascending,
                                      in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }

    static func fetchAll(matching predicate: NSPredicate?,
                         sortBy key: String,
                         ascending: Bool,
                         completion:@escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(with: predicate,
                                      sortBy: key,
                                      ascending: ascending,
                                      in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }
}

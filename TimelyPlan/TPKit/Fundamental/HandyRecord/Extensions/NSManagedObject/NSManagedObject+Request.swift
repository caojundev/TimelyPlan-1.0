//
//  NSManagedObject+Request.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/12.
//

import Foundation
import CoreData

// MARK: - 类型别名与全局配置

/// 排序条件：由排序键和排序方向组成
typealias SortTerm = (key: String, ascending: Bool)

/// 默认批量获取数量
/// 用于控制单次查询返回的对象数量，优化内存使用
var HandyRecordDefaultBatchSize: Int = 20

// MARK: - 查询请求构建

extension NSManagedObject {
    
    // MARK: 批量大小配置
    
    /// 默认批量获取大小
    /// 线程安全的属性访问器，使用 objc_sync 确保多线程环境下的安全读写
    static var defaultBatchSize: Int {
        get {
            return HandyRecordDefaultBatchSize
        }
        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            HandyRecordDefaultBatchSize = newValue
        }
    }
    
    // MARK: 基础查询请求
    
    /// 创建获取所有实体的基础查询请求
    /// - Parameter context: 托管对象上下文
    /// - Returns: 配置了实体的查询请求
    class func fetchAllRequest(in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription(in: context)
        return request
    }
    
    /// 创建带谓词过滤的查询请求
    /// - Parameters:
    ///   - predicate: 过滤谓词，nil 表示不过滤
    ///   - context: 托管对象上下文
    /// - Returns: 配置了实体和谓词的查询请求
    class func fetchAllRequest(with predicate: NSPredicate?,
                               in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let request = fetchAllRequest(in: context)
        request.predicate = predicate
        return request
    }
    
    // MARK: 排序查询请求
    
    /// 创建单键排序的查询请求
    /// - Parameters:
    ///   - predicate: 过滤谓词（可选）
    ///   - key: 排序键
    ///   - ascending: 是否升序排列
    ///   - context: 托管对象上下文
    /// - Returns: 配置了排序描述符的查询请求
    class func fetchAllRequest(with predicate: NSPredicate? = nil,
                               sortBy key: String,
                               ascending: Bool,
                               in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let request = fetchAllRequest(with: predicate, in: context)
        
        let sortDescriptor = NSSortDescriptor(key: key, ascending: ascending)
        request.sortDescriptors = [sortDescriptor]
        return request
    }

    /// 创建多键排序的查询请求
    /// - Parameters:
    ///   - predicate: 过滤谓词（可选）
    ///   - sortTerms: 排序条件数组，按数组顺序依次应用排序
    ///   - context: 托管对象上下文
    /// - Returns: 配置了多个排序描述符的查询请求
    class func fetchAllRequest(with predicate: NSPredicate?,
                               sortTerms: [SortTerm]?,
                               in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let request = fetchAllRequest(with: predicate, in: context)
        
        // 构建排序描述符数组
        let sortTerms = sortTerms ?? []
        let sortDescriptors = sortTerms.map { sortTerm in
            NSSortDescriptor(key: sortTerm.key, ascending: sortTerm.ascending)
        }
        
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    // MARK: 属性值匹配查询
    
    /// 创建属性值精确匹配的查询请求
    /// - Parameters:
    ///   - property: 属性名称
    ///   - value: 匹配值
    ///   - context: 托管对象上下文
    /// - Returns: 配置了相等谓词的查询请求
    class func fetchAllRequest(where property: String,
                               isEqualTo value: Any,
                               in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [property, value])
        let request = fetchAllRequest(in: context)
        request.predicate = predicate
        return request
    }
}

// MARK: - 同步查询执行

extension NSManagedObject {
    
    // MARK: 泛型查询
    
    /// 执行泛型查询请求（同步）
    /// - Parameters:
    ///   - request: 泛型查询请求
    ///   - context: 托管对象上下文
    /// - Returns: 查询结果数组，失败返回 nil
    class func executeFetchRequest<T: NSManagedObject>(
        _ request: NSFetchRequest<T>,
        in context: NSManagedObjectContext
    ) -> [T]? {
        guard let request = request as? NSFetchRequest<NSFetchRequestResult> else {
            debugPrint("查询请求类型转换失败")
            return nil
        }
        
        let results = executeFetchRequest(request, in: context)
        return results as? [T]
    }
    
    // MARK: 标准查询
    
    /// 在指定上下文中执行查询请求（同步）
    /// - Parameters:
    ///   - request: 查询请求
    ///   - context: 托管对象上下文
    /// - Returns: 查询结果数组，失败返回 nil
    /// - Note: 非默认上下文的结果会自动转换到默认上下文中
    class func executeFetchRequest(
        _ request: NSFetchRequest<NSFetchRequestResult>,
        in context: NSManagedObjectContext
    ) -> [NSFetchRequestResult]? {
        var results: [NSFetchRequestResult]?
        
        // 在上下文队列中执行查询
        context.performAndWait {
            do {
                results = try context.fetch(request)
            } catch {
                debugPrint("查询执行失败: \(error.localizedDescription)")
            }
        }
        
        // 如果查询在非默认上下文执行，需要将结果转移到默认上下文
        guard let managedObjects = results as? [NSManagedObject],
              context != .defaultContext else {
            return results
        }
        
        // 将对象转换到默认主队列上下文，确保线程安全
        let defaultContext = NSManagedObjectContext.defaultContext
        var transferredObjects: [NSManagedObject]?
        defaultContext.performAndWait {
            transferredObjects = managedObjects.map { object in
                defaultContext.object(with: object.objectID)
            }
        }
        
        return transferredObjects
    }
    
    /// 在默认上下文中执行查询请求（同步）
    /// - Parameter request: 查询请求
    /// - Returns: 查询结果数组，失败返回 nil
    class func executeFetchRequest(
        _ request: NSFetchRequest<NSFetchRequestResult>
    ) -> [NSFetchRequestResult]? {
        return executeFetchRequest(request, in: .defaultContext)
    }

    // MARK: 单个结果查询
    
    /// 在指定上下文中执行查询并返回第一个结果（同步）
    /// - Parameters:
    ///   - request: 查询请求（自动设置 fetchLimit 为 1）
    ///   - context: 托管对象上下文
    /// - Returns: 第一个查询结果，无结果返回 nil
    class func executeFetchRequestAndReturnFirstObject(
        request: NSFetchRequest<NSFetchRequestResult>,
        inContext context: NSManagedObjectContext
    ) -> NSFetchRequestResult? {
        request.fetchLimit = 1
        let results = executeFetchRequest(request, in: context)
        return results?.first
    }

    /// 在默认上下文中执行查询并返回第一个结果（同步）
    /// - Parameter request: 查询请求
    /// - Returns: 第一个查询结果，无结果返回 nil
    class func executeFetchRequestAndReturnFirstObject(
        request: NSFetchRequest<NSFetchRequestResult>
    ) -> NSFetchRequestResult? {
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: .defaultContext)
    }
}

// MARK: - 异步查询执行

extension NSManagedObject {
    
    // MARK: 异步查询
    
    /// 异步执行查询请求
    /// - Parameters:
    ///   - request: 查询请求
    ///   - completion: 查询完成回调，在主线程返回结果
    /// - Note: 在后台上下文执行查询，结果自动转换到默认上下文
    class func executeFetchRequest(
        _ request: NSFetchRequest<NSFetchRequestResult>,
        completion: @escaping ([NSFetchRequestResult]?) -> Void
    ) {
        // 创建后台上下文执行查询，避免阻塞主线程
        let context = NSManagedObjectContext.context(withParent: .defaultContext)
        
        context.perform {
            // 执行查询（可添加延迟用于测试异步行为）
            // Thread.sleep(forTimeInterval: 0.2)
            
            var results: [NSFetchRequestResult]?
            do {
                results = try context.fetch(request)
            } catch {
                debugPrint("异步查询执行失败: \(error.localizedDescription)")
            }
            
            // 如果结果不是托管对象数组，直接返回
            guard let managedObjects = results as? [NSManagedObject] else {
                completion(results)
                return
            }
            
            // 将结果转换到默认主队列上下文
            let defaultContext = NSManagedObjectContext.defaultContext
            defaultContext.performAndWait {
                let transferredObjects = managedObjects.map { object in
                    defaultContext.object(with: object.objectID)
                }
                completion(transferredObjects)
            }
        }
    }

    /// 异步执行泛型查询请求
    /// - Parameters:
    ///   - request: 泛型查询请求
    ///   - completion: 查询完成回调，返回类型安全的结果数组
    class func executeFetchRequest<T: NSManagedObject>(
        _ request: NSFetchRequest<T>,
        completion: @escaping ([T]?) -> Void
    ) {
        guard let request = request as? NSFetchRequest<NSFetchRequestResult> else {
            debugPrint("泛型查询请求类型转换失败")
            completion(nil)
            return
        }
        
        executeFetchRequest(request) { results in
            completion(results as? [T])
        }
    }

    // MARK: 异步单结果查询
    
    /// 异步执行查询并返回第一个结果
    /// - Parameters:
    ///   - request: 查询请求（自动设置 fetchLimit 为 1）
    ///   - completion: 查询完成回调，返回第一个结果
    class func executeFetchRequestAndReturnFirstObject(
        request: NSFetchRequest<NSFetchRequestResult>,
        completion: @escaping (NSFetchRequestResult?) -> Void
    ) {
        request.fetchLimit = 1
        executeFetchRequest(request) { results in
            completion(results?.first)
        }
    }
    
    // MARK: 异步计数查询
    
    /// 异步获取符合条件的实体数量
    /// - Parameters:
    ///   - predicate: 过滤谓词
    ///   - completion: 查询完成回调，返回实体数量
    class func fetchCount(
        withPredicate predicate: NSPredicate,
        completion: @escaping (Int) -> Void
    ) {
        let request = fetchAllRequest(with: predicate, in: .defaultContext)
        fetchCount(forRequest: request, completion: completion)
    }

    /// 异步获取查询请求的结果数量
    /// - Parameters:
    ///   - request: 查询请求
    ///   - completion: 查询完成回调，返回结果数量
    class func fetchCount(
        forRequest request: NSFetchRequest<NSFetchRequestResult>,
        completion: @escaping (Int) -> Void
    ) {
        // 在后台上下文执行计数查询
        let context = NSManagedObjectContext.context(withParent: .defaultContext)
        
        context.perform {
            do {
                let count = try context.count(for: request)
                completion(count)
            } catch {
                debugPrint("计数查询失败: \(error.localizedDescription)")
                completion(0)
            }
        }
    }
}

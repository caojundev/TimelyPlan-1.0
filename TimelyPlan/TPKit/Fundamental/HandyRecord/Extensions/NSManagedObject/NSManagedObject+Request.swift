//
//  NSManagedObject+Request.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/12.
//

import Foundation
import CoreData

typealias SortTerm = (key: String, ascending: Bool)

var HandyRecordDefaultBatchSize: Int = 20

extension NSManagedObject {
    
    /// 默认批量获取数目
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
    
    /// 获取所有条目请求
    class func fetchAllRequest(in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription(in: context)
        return request
    }
    
    class func fetchAllRequest(with predicate: NSPredicate?,
                               in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let request = fetchAllRequest(in: context)
        request.predicate = predicate
        return request
    }
    
    /// 排序条目
    class func fetchAllRequest(with predicate: NSPredicate? = nil,
                               sortedBy key: String,
                               ascending: Bool,
                               in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let request = fetchAllRequest(in: context)
        if let predicate = predicate {
            request.predicate = predicate
        }

        let sortDescriptor = NSSortDescriptor(key: key, ascending: ascending)
        request.sortDescriptors = [sortDescriptor]
        return request
    }

    class func fetchAllRequest(with predicate: NSPredicate?,
                               sortTerms: [SortTerm]?,
                               in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let request = fetchAllRequest(in: context)
        if let predicate = predicate {
            request.predicate = predicate
        }

        var sortDescriptors = [NSSortDescriptor]()
        let sortTerms = sortTerms ?? []
        for sortTerm in sortTerms {
            let sortDescriptor = NSSortDescriptor(key: sortTerm.key,
                                                  ascending: sortTerm.ascending)
            sortDescriptors.append(sortDescriptor)
        }
        
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    class func fetchAllRequest(where property: String,
                               isEqualTo value: Any,
                               in context: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [property, value])
        let request = fetchAllRequest(in: context)
        request.predicate = predicate
        return request
    }
    
}

// MARK: - 执行请求
extension NSManagedObject {
    
    class func executeFetchRequest<T: NSManagedObject>(_ request: NSFetchRequest<T>, in context: NSManagedObjectContext) -> [T]? {
        if let request = request as? NSFetchRequest<NSFetchRequestResult> {
            let results = executeFetchRequest(request, in: context)
            return results as? [T]
        }
         
        return nil
    }
    
    /// 在特定上下文中执行获取请求，返回所有结果数组
    class func executeFetchRequest(_ request: NSFetchRequest<NSFetchRequestResult>, in context: NSManagedObjectContext) -> [NSFetchRequestResult]? {
        var results: [NSFetchRequestResult]? = nil
        context.performAndWait {
            do{
                results = try context.fetch(request)
            } catch let error{
                debugPrint("Error:\(error.localizedDescription)")
            }
        }
        
        guard let results = results as? [NSManagedObject],
              context != .defaultContext else {
            return results
        }
        
        /// 将托管对象转移到其主托管上下文
        let defaultContext = NSManagedObjectContext.defaultContext
        var transferredObjects: [NSManagedObject]?
        defaultContext.performAndWait {
            transferredObjects = results.map { object in
                return defaultContext.object(with: object.objectID)
            }
        }
        
        return transferredObjects
    }
    
    class func executeFetchRequest(_ request: NSFetchRequest<NSFetchRequestResult>) -> [NSFetchRequestResult]? {
        let context = NSManagedObjectContext.defaultContext
        return executeFetchRequest(request, in: context)
    }

    /// 在特定上下文中执行获取请求，返回第一个结果
    class func executeFetchRequestAndReturnFirstObject(request: NSFetchRequest<NSFetchRequestResult>, inContext context: NSManagedObjectContext) -> NSFetchRequestResult? {
        request.fetchLimit = 1
        let results = executeFetchRequest(request, in: context)
        return results?.first
    }

    class func executeFetchRequestAndReturnFirstObject(request: NSFetchRequest<NSFetchRequestResult>) -> NSFetchRequestResult? {
        let context = NSManagedObjectContext.defaultContext
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context)
    }
}

extension NSManagedObject {
    
    class func executeFetchRequest(_ request: NSFetchRequest<NSFetchRequestResult>,
                                   completion: @escaping([NSFetchRequestResult]?) -> Void) {
        let context: NSManagedObjectContext = .context(withParent: .defaultContext)
        context.perform {
            var results: [NSFetchRequestResult]? = nil
            do{
               results = try context.fetch(request)
            } catch let error{
                debugPrint("Error:\(error.localizedDescription)")
            }
            
            guard let results = results as? [NSManagedObject] else {
                completion(results)
                return
            }
            
            /// 将托管对象转移到其主托管上下文
            let defaultContext = NSManagedObjectContext.defaultContext
            defaultContext.performAndWait {
                let transferredObjects = results.map { object in
                    return defaultContext.object(with: object.objectID)
                }
                
                completion(transferredObjects)
            }
        }
    }

    class func executeFetchRequest<T: NSManagedObject>(_ request: NSFetchRequest<T>,
                                                       completion: @escaping([T]?) -> Void) {
        if let request = request as? NSFetchRequest<NSFetchRequestResult> {
            executeFetchRequest(request) { results in
                completion(results as? [T])
            }
        }
         
        completion(nil)
    }

    /// 在特定上下文中执行获取请求，返回第一个结果
    class func executeFetchRequestAndReturnFirstObject(request: NSFetchRequest<NSFetchRequestResult>,
                                                       completion: @escaping(NSFetchRequestResult?) -> Void) {
        request.fetchLimit = 1
        executeFetchRequest(request) { results in
            completion(results?.first)
        }
    }
    
    /// 异步获取查询结果数目
    class func fetchCount(withPredicate predicate: NSPredicate,
                          completion: @escaping(Int) -> Void) {
        let request = fetchAllRequest(with: predicate, in: .defaultContext)
        fetchCount(forRequest: request, completion: completion)
    }

    class func fetchCount(forRequest request: NSFetchRequest<NSFetchRequestResult>, completion: @escaping (Int) -> Void) {
        let context: NSManagedObjectContext = .context(withParent: .defaultContext)
        context.perform {
            do{
               let count = try context.count(for: request)
                completion(count)
            } catch let error{
                debugPrint("Error:\(error.localizedDescription)")
                completion(0)
            }
        }
    }
    
}

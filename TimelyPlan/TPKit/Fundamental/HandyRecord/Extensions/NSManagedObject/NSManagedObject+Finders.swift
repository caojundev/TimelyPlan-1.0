//
//  NSManagedObject+Finders.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/12.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    // MARK: - Find All
    static func findAll<T>(in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }

    static func findAll<T>(with predicate: NSPredicate?,
                           sortTerms: [SortTerm]?,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(with: predicate,
                                      sortTerms: sortTerms,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }

    static func findAll<T>(with predicate: NSPredicate,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(with: predicate, in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }
    
    static func findAll<T>(where attribute: String,
                           isEqualTo value: Any,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(where: attribute,
                                      isEqualTo: value,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }
    
    static func findAll<T>(where attribute: String,
                           isEqualTo value: Any?,
                           sortedBy key: String,
                           ascending: Bool,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        
        let predicate: NSPredicate
        if let value = value {
            predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, value])
        } else {
            predicate = NSPredicate(format: "%K = nil", attribute)
        }
        
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }
    
    static func findAll<T>(with predicate: NSPredicate? = nil,
                           sortedBy key: String,
                           ascending: Bool,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }

    
    
    // MARK: - Find First
    static func findFirst(in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    static func findFirst(sortedBy key: String,
                          ascending: Bool,
                          in context: NSManagedObjectContext) -> Self? {
        return findFirst(withPredicate: nil, sortedBy: key, ascending: ascending, in: context)
    }
    
    static func findFirst(where attribute: String,
                          isEqualTo value: Any,
                          in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(where: attribute,
                                      isEqualTo: value,
                                      in: context)
        return executeFetchRequestAndReturnFirstObject(request: request,
                                                       inContext: context) as? Self
    }

    static func findFirstOrCreate(where attribute: String,
                                  isEqualTo value: Any,
                                  in context: NSManagedObjectContext) -> Self {
        if let result = findFirst(where: attribute, isEqualTo: value, in: context) {
            return result
        }
        
        let result = Self.createEntity(in: context)
        result.setValue(value, forKey: attribute)
        return result
    }

    static func findFirst(withPredicate predicate: NSPredicate?,
                          in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(with: predicate, in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    static func findFirst(withPredicate predicate: NSPredicate?,
                          sortedBy key: String,
                          ascending: Bool,
                          in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    static func findFirst(withPredicate predicate: NSPredicate?,
                          retrieveAttributes: [String],
                          in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(in: context)
        request.predicate = predicate
        request.propertiesToFetch = properties(names: retrieveAttributes, in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    static func findFirst(withPredicate predicate: NSPredicate?,
                          sortedBy key: String,
                          ascending: Bool,
                          retrieveAttributes: [String],
                          in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: context)
        request.propertiesToFetch = properties(names: retrieveAttributes, in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }
}


extension NSManagedObject {
    
    // MARK: - Find All
    static func findAll(completion:@escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }

    static func findAll(with predicate: NSPredicate,
                        completion: @escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(with: predicate, in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }
    
    static func findAll(with predicate: NSPredicate,
                        sortTerms: [SortTerm]?,
                        completion: @escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(with: predicate, sortTerms: sortTerms, in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }
    
    static func findAll(with predicate: NSPredicate,
                        sortedBy key: String,
                        ascending: Bool,
                        completion: @escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }
    
    static func findFirst(withPredicate predicate: NSPredicate?,
                          completion: @escaping(NSFetchRequestResult?) -> Void) {
        let request = fetchAllRequest(with: predicate, in: .defaultContext)
        executeFetchRequestAndReturnFirstObject(request: request, completion: completion)
    }
    
    
    /*
     
     //    /// 分组
     //    static func findAll(withPredicate predicate: NSPredicate,
     //                        propertiesToGroupBy: [Any]?,
     //                        propertiesToFetch: [Any]?,
     //                        completion: @escaping([NSFetchRequestResult]?) -> Void) {
     //        let request = fetchAllRequest(with: predicate, in: .defaultContext)
     //        // 设置返回的结果类型为分组结果
     //        request.resultType = .dictionaryResultType
     //        request.propertiesToGroupBy = propertiesToGroupBy
     //        request.propertiesToFetch = propertiesToFetch
     //        executeFetchRequest(request, completion: completion)
     //    }
     //
         
         
    static func findAll<T>(sortedBy sortTerms: [SortTerm],
                           ascending: Bool,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        return findAll(sortedBy: sortTerms,
                       ascending: ascending,
                       predicate: nil,
                       in: context)
    }

    static func findAll<T>(sortedBy sortTerms: [SortTerm]?,
                           ascending: Bool,
                           predicate: NSPredicate?,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(sortedBy: sortTerms,
                                      ascending: ascending,
                                      predicate: predicate,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }

    static func findAll<T>(withPredicate predicate: NSPredicate,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(with: predicate, in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }

    static func findAll<T>(where attribute: String,
                           isEqualTo value: Any,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let request = fetchAllRequest(where: attribute,
                                      isEqualTo: value,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }
    
    static func findAll<T>(where attribute: String,
                           isEqualTo value: Any,
                           sortedBy key: String,
                           ascending: Bool,
                           in context: NSManagedObjectContext) -> [T]? where T: NSFetchRequestResult {
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, value])
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: context)
        return executeFetchRequest(request, in: context) as? [T]
    }
    
    // MARK: - Find First
    static func findFirst(in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    static func findFirst(sortedBy key: String,
                          ascending: Bool,
                          in context: NSManagedObjectContext) -> Self? {
        return findFirst(withPredicate: nil, sortedBy: key, ascending: ascending, in: context)
    }
    
    static func findFirst(where attribute: String,
                          isEqualTo value: Any,
                          in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(where: attribute,
                                      isEqualTo: value,
                                      in: context)
        return executeFetchRequestAndReturnFirstObject(request: request,
                                                       inContext: context) as? Self
    }

    static func findFirstOrCreate(where attribute: String,
                                  isEqualTo value: Any,
                                  in context: NSManagedObjectContext) -> Self {
        if let result = findFirst(where: attribute, isEqualTo: value, in: context) {
            return result
        }
        
        let result = Self.createEntity(in: context)
        result.setValue(value, forKey: attribute)
        return result
    }
     
    static func findFirst(withPredicate predicate: NSPredicate?,
                          sortedBy key: String,
                          ascending: Bool,
                          in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    static func findFirst(withPredicate predicate: NSPredicate?,
                          retrieveAttributes: [String],
                          in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(in: context)
        request.predicate = predicate
        request.propertiesToFetch = properties(names: retrieveAttributes, in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }

    static func findFirst(withPredicate predicate: NSPredicate?,
                          sortedBy key: String,
                          ascending: Bool,
                          retrieveAttributes: [String],
                          in context: NSManagedObjectContext) -> Self? {
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: context)
        request.propertiesToFetch = properties(names: retrieveAttributes, in: context)
        return executeFetchRequestAndReturnFirstObject(request: request, inContext: context) as? Self
    }
    */
}

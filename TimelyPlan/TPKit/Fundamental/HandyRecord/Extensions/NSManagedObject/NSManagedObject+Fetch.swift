//
//  NSManagedObject+Fetch.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/10.
//

import Foundation
import CoreData

// MARK: - 异步获取
extension NSManagedObject {
    
    
    static func fetchFirst(matching predicate: NSPredicate?,
                           completion: @escaping(NSFetchRequestResult?) -> Void) {
        let request = fetchAllRequest(with: predicate, in: .defaultContext)
        executeFetchRequestAndReturnFirstObject(request: request, completion: completion)
    }
    
    // MARK: - Fetch All
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
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }

    static func fetchAll(matching predicate: NSPredicate?,
                         sortBy key: String,
                         ascending: Bool,
                         completion:@escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }
    
    
    
}

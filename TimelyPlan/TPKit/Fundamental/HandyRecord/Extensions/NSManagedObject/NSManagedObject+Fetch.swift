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
    
    static func fetchAll(withPredicate predicate: NSPredicate?,
                         sortedBy key: String,
                         ascending: Bool,
                         completion:@escaping([NSFetchRequestResult]?) -> Void) {
        let request = fetchAllRequest(with: predicate,
                                      sortedBy: key,
                                      ascending: ascending,
                                      in: .defaultContext)
        executeFetchRequest(request, completion: completion)
    }
    
}

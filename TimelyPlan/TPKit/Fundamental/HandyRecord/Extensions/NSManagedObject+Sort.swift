//
//  NSManagedObject+Sort.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/1.
//

import Foundation
import CoreData

// MARK: - 同步排序因子

let kIdentifierKeyName = "identifier"

protocol SortableIdentifiable: Sortable {
    
    var identifiableKey: String { get }
}

extension NSManagedObject {

    /// 获取特定标识的列表
    static func getItem(with identifier: String) -> Self? {
        let condition: PredicateCondition = (kIdentifierKeyName, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        return findFirst(withPredicate: predicate, in: .defaultContext)
    }
    
    static func getItems(with identifiers: [String]) -> [NSManagedObject]? {
        let condition: PredicateCondition = (kIdentifierKeyName, .belongsTo(identifiers))
        let predicate = NSPredicate.predicate(with: condition)
        let results: [NSManagedObject]? = findAll(with: predicate, in: .defaultContext)
        return results
    }
    
    static func getIdentifiableItems(with items: [SortableIdentifiable]) -> [NSManagedObject]? {
        let identifiers = items.map{ $0.identifiableKey }
        return getItems(with: identifiers)
    }
    
    @discardableResult
    static func syncOrders(for items: [SortableIdentifiable]) -> Bool {
        guard let cdItems = getIdentifiableItems(with: items) else {
            return false
        }
        
        items.updateOrders()
        syncOrders(from: items, to: cdItems)
        return true
    }
    
    private static func syncOrders(from items: [SortableIdentifiable], to cdItems: [NSManagedObject]) {
        let orderLookup = items.reduce(into: [String: Int64]()) { result, item in
            result[item.identifiableKey] = item.order
        }
        
        cdItems.forEach { cdItem in
            if var item = cdItem as? SortableIdentifiable,
               let order = orderLookup[item.identifiableKey] {
                item.order = order
            }
        }
    }
}

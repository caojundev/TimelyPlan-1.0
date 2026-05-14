//
//  CDTodoFilter+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/19.
//

import Foundation
import CoreData

struct TodoFilterKey {
    static var name = "name"
    static let order = "order"
}

extension CDTodoFilter: SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    /// 更新过滤器
    func update(with editingFilter: TodoEditingFilter) {
        self.name = editingFilter.name
        self.colorHex = editingFilter.color.hexString
        self.ruleJSON = editingFilter.rule?.jsonString()
    }
    
    // MARK: - 获取
    static func getFilters() -> [CDTodoFilter]? {
        return findAll(with: nil,
                       sortedBy: TodoFilterKey.order,
                       ascending: true,
                       in: .defaultContext)
    }
    
    static func fetchFilters(completion: @escaping([CDTodoFilter]?) -> Void) {
        findAll(with: nil, sortedBy: TodoFilterKey.order, ascending: true) { results in
            completion(results as? [CDTodoFilter])
        }
    }
    
    // MARK: - 处理
    static func createFilter(with editingFilter: TodoEditingFilter,
                             onTop: Bool = false) -> CDTodoFilter? {
        guard let name = editingFilter.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 else {
            return nil
        }
        
        let filter = newFilter(with: editingFilter)
        if onTop {
            filter.order = minimumOrder - kOrderedStep
        } else {
            filter.order = maximumOrder + kOrderedStep
        }
        
        return filter
    }
    
    static func newFilter(with editingFilter: TodoEditingFilter) -> CDTodoFilter {
        let filter = CDTodoFilter.createEntity(in: .defaultContext)
        filter.identifier = UUID().uuidString
        filter.creationDate = .now
        filter.update(with: editingFilter)
        return filter
    }
    
    static func updateFilter(_ filter: TodoFilter,
                             with editingFilter: TodoEditingFilter) -> Bool {
        if filter.editingFilter == editingFilter {
            return false
        }
        
        if let cdFilter = getItem(with: filter.identifier) {
            cdFilter.update(with: editingFilter)
            return true
        }
        
        return false
    }
    
    static func deleteFilter(_ filter: TodoFilter) -> Bool {
        guard let cdFilter = getItem(with: filter.identifier) else {
            return false
        }
        
        let context = NSManagedObjectContext.defaultContext
        context.delete(cdFilter)
        return true
    }
    
    /// 重新排序
    static func reorderFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) -> Bool {
        var reorderFilters = filters
        reorderFilters.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        return syncOrders(for: reorderFilters)
    }
}

extension Array where Element == CDTodoFilter {
    
    var filters: [TodoFilter] {
        self.map{ TodoFilter(content: $0) }
    }
}

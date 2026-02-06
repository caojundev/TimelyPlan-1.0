//
//  TodoFilterManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation
import CoreData

struct TodoFilterKey {
    static var name = "name"
    static let order = "order"
}

class TodoFilterManager {

    let updater = TodoFilterProcessorUpdater()
    
    private var filters: [TodoFilter]
    
    init() {
        self.filters = TodoFilterManager.getFilters()
    }
    
    // MARK: - Providers
    /// 获取所有过滤器
    func getFilters() -> [TodoFilter] {
        return filters
    }

    // MARK: - Processors

    /// 新建过滤器
    func createFilter(with editFilter: TodoEditFilter) {
        guard let name = editFilter.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 else {
            return
        }
        
        /// 创建新过滤器
        let order = filters.maxOrder - kOrderedStep
        let filter = TodoFilter.newFilter(with: editFilter, order: order)
        filters.insert(filter, at: 0)
        updater.didCreateTodoFilter(filter)
        todo.save()
    }
    
    /// 更新过滤器信息
    func updateFilter(_ filter: TodoFilter, with editFilter: TodoEditFilter) {
        if filter.editFilter == editFilter {
            return
        }
        
        /// 更新过滤器
        filter.update(with: editFilter)
        updater.didUpdateTodoFilter(filter)
        todo.save()
    }
    
    /// 删除过滤器
    func deleteFilter(_ filter: TodoFilter) {
        guard let _ = filters.remove(filter) else {
            return
        }

        NSManagedObjectContext.defaultContext.delete(filter)
        updater.didDeleteTodoFilter(filter)
        todo.save()
    }

    /// 重新排序过滤器
    func reorderFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) -> Bool  {
        var reorderFilters = filters
        reorderFilters.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        reorderFilters.updateOrders()
        
        /// 过滤器重新排序
        self.filters = self.filters.orderedElements(ascending: true)
        updater.didReorderTodoFilter(in: filters, fromIndex: fromIndex, toIndex: toIndex)
        todo.save()
        return true
    }
    
    // MARK: - 数据库获取数据
    /// 异步获取所有名称包含特定文本的所有过滤器
    static func fetchFilters(containText text: String, completion:(@escaping([TodoFilter]?) -> Void)) {
        let condition: PredicateCondition = (TodoFilterKey.name, .contains(text))
        let predicate = NSPredicate.predicate(with: condition)
        TodoFilter.fetchAll(withPredicate: predicate,
                            sortedBy: TodoFilterKey.order,
                            ascending: true) { results in
            if let filters = results as? [TodoFilter], filters.count > 0 {
                completion(filters)
            } else {
                completion(nil)
            }
        }
    }
    
    /// 同步获取所有过滤器
    static func getFilters() -> [TodoFilter] {
        let results: [TodoFilter]? = TodoFilter.findAll(with: nil,
                                                        sortedBy: TodoFilterKey.order,
                                                        ascending: true,
                                                        in: .defaultContext)
        if let results = results {
            return results
        }

        return []
    }
}

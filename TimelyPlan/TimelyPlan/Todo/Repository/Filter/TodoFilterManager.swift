//
//  TodoFilterManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation
import CoreData

class TodoFilterManager {

    let updater = TodoFilterProcessorUpdater()
    
    func getFilters() -> [TodoFilter]? {
        return CDTodoFilter.getFilters()?.filters
    }
    
    func getFilter(of identifier: String) -> TodoFilter? {
        guard let cdFilter = CDTodoFilter.getItem(with: identifier) else {
            return nil
        }
    
        return TodoFilter(content: cdFilter)
    }
    
    func fetchFilters(completion: @escaping([TodoFilter]?) -> Void) {
        CDTodoFilter.fetchFilters { results in
            completion(results?.filters)
        }
    }
    
    /// 根据多个标识符异步批量获取过滤器，一次查询取出全部过滤器，按传入顺序返回
    func fetchFilters(of identifiers: [String], completion: @escaping([TodoFilter]?) -> Void) {
        guard !identifiers.isEmpty else {
            completion(nil)
            return
        }
        
        CDTodoFilter.fetchFilters(for: identifiers) { coreDataFilters in
            let filters = coreDataFilters?.filters ?? []
            let filtersByIdentifier = Dictionary(filters.map { ($0.identifier, $0) },
                                                 uniquingKeysWith: { first, _ in first })
            let orderedFilters = identifiers.compactMap { filtersByIdentifier[$0] }
            completion(orderedFilters.isEmpty ? nil : orderedFilters)
        }
    }
    
    // MARK: - Processors
    /// 新建过滤器
    func createFilter(with editingFilter: TodoEditingFilter) {
        let onTop = TodoSetting.shared.addFilterOnTop
        guard let content = CDTodoFilter.createFilter(with: editingFilter, onTop: onTop) else {
            return
        }
        
        let filter = TodoFilter(content: content)
        HandyRecord.updateChangeCount()
        updater.didCreateTodoFilter(filter)
    }
    
    /// 更新过滤器
    func updateFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {
        guard CDTodoFilter.updateFilter(filter, with: editingFilter) else {
            return
        }
        
        HandyRecord.updateChangeCount()
        updater.didUpdateTodoFilter(filter, with: editingFilter)
    }
    
    /// 删除过滤器
    func deleteFilter(_ filter: TodoFilter) {
        guard CDTodoFilter.deleteFilter(filter) else {
            return
        }
        
        HandyRecord.updateChangeCount()
        updater.didDeleteTodoFilter(filter)
    }

    /// 重新排序过滤器
    func reorderFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        guard CDTodoFilter.reorderFilter(in: filters, fromIndex: fromIndex, toIndex: toIndex) else {
            return
        }
        
        HandyRecord.updateChangeCount()
        updater.didReorderTodoFilter(in: filters, fromIndex: fromIndex, toIndex: toIndex)
    }
    
}

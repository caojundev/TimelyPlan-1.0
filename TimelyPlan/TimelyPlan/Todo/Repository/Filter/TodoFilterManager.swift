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

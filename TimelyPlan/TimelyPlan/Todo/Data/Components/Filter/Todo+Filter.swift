//
//  Todo+Filter.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation

extension Todo {
    
    func getFilters() -> [TodoFilter] {
        return filterManager.getFilters()
    }
    
    func createFilter(with editFilter: TodoEditFilter) {
        filterManager.createFilter(with: editFilter)
    }

    func deleteFilter(_ filter: TodoFilter) {
        filterManager.deleteFilter(filter)
    }
    
    func updateFilter(_ filter: TodoFilter, with editFilter: TodoEditFilter) {
        filterManager.updateFilter(filter, with: editFilter)
    }

    func reorderFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) -> Bool {
        return filterManager.reorderFilter(in: filters, fromIndex: fromIndex, toIndex: toIndex)
    }
    
    // MARK: - 异步获取任务
    func fetchTasks(filterRule: TodoFilterRule,
                    showCompleted: Bool,
                    sort: TodoSort,
                    completion: @escaping([TodoTask]?) -> Void) {
        guard let predicate = predicate(for: filterRule, showCompleted: showCompleted) else {
            completion(nil)
            return
        }
        
        let sortTerms = sortTerms(for: sort)
        TodoTask.findAll(with: predicate, sortTerms: sortTerms) { results in
            let tasks = results as? [TodoTask]
            completion(tasks)
        }
    }
    
    private func predicate(for filterRule: TodoFilterRule, showCompleted: Bool) -> NSPredicate? {
        guard let rulePredicate = filterRule.predicate else {
            return nil
        }

        var conditions: [PredicateCondition] = [(TodoTaskKey.isRemoved, .isFalse)]
        if !showCompleted {
            conditions.append((TodoTaskKey.isCompleted, .isFalse))
        }
        
        let additionalPredicate = conditions.andPredicate()
        return NSCompoundPredicate(andPredicateWithSubpredicates: [rulePredicate, additionalPredicate])
    }
    
    private func sortTerms(for sort: TodoSort) -> [SortTerm] {
        var sortTerms = [sort.sortTerm]
        if sort.type != .creationDate {
            /// 以创建日期辅助排序
            sortTerms.append((TodoTaskKey.creationDate, sort.order == .ascending))
        }
   
        return sortTerms
    }
}

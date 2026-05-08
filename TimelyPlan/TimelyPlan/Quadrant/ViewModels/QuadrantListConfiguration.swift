//
//  QuadrantListConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/7.
//

import Foundation

class QuadrantListConfiguration: TodoListConfiguration {
    
    let quadrant: Quadrant
    
    private(set) var filterRule: TodoFilterRule
    
    init(quadrant: Quadrant, filterRule: TodoFilterRule) {
        self.quadrant = quadrant
        self.filterRule = filterRule
        super.init(identifier: quadrant.identifier)
    }
    
    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return QuadrantDetailViewController(interactor: interactor)
    }

    override func allowListOptions() -> [TodoListOption]? {
        return [.select, .showCompleted, .showDetail, .group, .sort, .edit]
    }
    
    override func allowGroupTypes() -> [TodoGroupType] {
        return [.default, .startDate, .dueDate, .priority]
    }
    
    override func allowSortTypes() -> [TodoSortType] {
        return [.creationDate, .modificationDate, .startDate, .dueDate]
    }
    
    override var preferredSortOrder: TodoSortOrder {
        return .descending
    }
    
    override func quickAddTask() -> TodoQuickAddTask? {
        return filterRule.matchingQuickAddTask
    }
    
    override func detailOption() -> TodoTaskDetailOption {
        return .allExceptCompletionDate
    }
    
    override func canAddTask() -> Bool {
        return true
    }
    
    /// 更新过滤器
    func updateFilterRule(_ filterRule: TodoFilterRule) {
        self.filterRule = filterRule
    }
    
}

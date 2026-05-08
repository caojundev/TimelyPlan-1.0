//
//  QuadrantListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/7.
//

import Foundation

class QuadrantListInteractor: TodoListInteractor,
                              TPMidnightUpdatable {
    
    var quadrant: Quadrant {
        return quadrantConfiguration.quadrant
    }
    
    var filterRule: TodoFilterRule {
        return quadrantConfiguration.filterRule
    }
    
    var matchingQuickAddTask: TodoQuickAddTask? {
        return configuration.quickAddTask()
    }
    
    var quadrantConfiguration: QuadrantListConfiguration{
       return configuration as! QuadrantListConfiguration
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        TPMidnightScheduler.shared.addUpdater(self)
    }

    override func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        todo.fetchTasks(filterRule: filterRule,
                        showCompleted: showCompleted,
                        completion: completion)
    }

    override func title() -> TextRepresentable? {
        return quadrant.title
    }

    /// 更新过滤器
    func updateFilterRule(_ filterRule: TodoFilterRule) {
        quadrantConfiguration.updateFilterRule(filterRule)
    }
    
    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        guard filterRule.dateFilterValue != nil else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
}

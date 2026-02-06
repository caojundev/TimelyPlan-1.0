//
//  QuadrantFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/10.
//

import Foundation

class QuadrantFetcher {
    
    /// 当前象限
    let quadrant: Quadrant
    
    private var sort = TodoSort(type: .startDate, order: .ascending)
    
    init(quadrant: Quadrant) {
        self.quadrant = quadrant
    }
    
    func fetchGroups(completion: @escaping([TodoGroup]?) -> Void) {
        let showCompleted = QuadrantSettingAgent.shared.showCompleted
        let filterRule = QuadrantSettingAgent.shared.filterRule(for: quadrant)
        let sort = TodoSort(type: .startDate, order: .descending)
        todo.fetchTasks(filterRule: filterRule,
                        showCompleted: showCompleted,
                        sort: sort) { tasks in
            guard let tasks = tasks, tasks.count > 0 else {
                completion(nil)
                return
            }
            
            let groups = tasks.statusClassifiedTaskGroups(shouldCollapse: nil)
            completion(groups)
        }
    }
}

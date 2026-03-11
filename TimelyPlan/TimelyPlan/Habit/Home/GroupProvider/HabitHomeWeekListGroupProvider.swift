//
//  HabitHomeWeekListGroupProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/11.
//

import Foundation

class HabitHomeWeekListGroupProvider: HabitTaskBaseListGroupProvider {
    
    func fetchGroups(in period: HabitDatePeriod, completion: @escaping ([HabitTaskGroup]?) -> Void) {
        loadTasksIfNeeded(in: period) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }
            
            let groups = HabitPeriodTaskOrganizer.groupAll(from: tasks, with: .all)
            completion(groups)
        }
    }
    
    private func loadTasksIfNeeded(in period: HabitDatePeriod,
                                   completion: @escaping ([HabitPeriodTask]?) -> Void) {
        guard self.shouldRefresh else {
            completion(self.tasks)
            return
        }

        /// 刷新任务列表
        let requestID = requestManager.executeRequest()
        TimelyPlan.habit.fetchPeriodTasks(in: period) { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(nil)
                return
            }
            
            self.tasks = tasks
            self.setNeedsRefresh(false)
            completion(self.tasks)
        }
    }
    
}

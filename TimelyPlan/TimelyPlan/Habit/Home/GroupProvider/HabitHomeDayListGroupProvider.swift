//
//  HabitHomeDayListGroupProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/11.
//

import Foundation

class HabitHomeDayListGroupProvider: HabitTaskBaseListGroupProvider {
    
    func fetchGroups(on date: Date,
                     with filterType: HabitTaskFilterType,
                     completion: @escaping ([HabitTaskGroup]?) -> Void) {
        loadTasksIfNeeded(on: date) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }
            
            let groups = HabitPeriodTaskOrganizer.groupAll(from: tasks, with: filterType)
            completion(groups)
        }
    }
    
    private func loadTasksIfNeeded(on date: Date,
                                   completion: @escaping ([HabitPeriodTask]?) -> Void) {
        guard self.shouldRefresh else {
            completion(self.tasks)
            return
        }

        /// 刷新任务列表
        let requestID = requestManager.executeRequest()
        TimelyPlan.habit.fetchScheduledPeriodTasks(on: date) { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(nil)
                return
            }
            
            self.tasks = tasks ?? []
            self.setNeedsRefresh(false)
            completion(self.tasks)
        }
    }
}

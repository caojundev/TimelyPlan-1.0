//
//  HabitHomeDayListGroupProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/11.
//

import Foundation

class HabitHomeDayListGroupProvider: HabitTaskBaseListGroupProvider {
    
    var date: Date?
    
    func fetchGroups(on date: Date,
                     with filterType: HabitTaskFilterType,
                     completion: @escaping ([HabitTaskGroup]?) -> Void) {
        loadTasksIfNeeded(on: date) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }
            
            let groups = HabitPeriodItemOrganizer.groupAll(from: tasks, with: filterType)
            completion(groups)
        }
    }
    
    private func loadTasksIfNeeded(on date: Date,
                                   completion: @escaping ([HabitPeriodItem]?) -> Void) {
        var bRefresh: Bool = self.shouldRefresh
        if !bRefresh {
            if let lastDate = self.date {
                bRefresh = !date.isInSameDayAs(lastDate)
            } else {
                bRefresh = true
            }
        }
        
        guard bRefresh else {
            completion(self.periodItems)
            return
        }

        /// 刷新任务列表
        let requestID = requestManager.executeRequest()
        TimelyPlan.habit.fetchScheduledPeriodItems(on: date) { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(nil)
                return
            }
            
            self.periodItems = tasks ?? []
            self.date = date
            self.setNeedsRefresh(false)
            completion(self.periodItems)
        }
    }
}

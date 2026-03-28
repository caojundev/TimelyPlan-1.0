//
//  HabitHomeWeekListGroupProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/11.
//

import Foundation

class HabitHomeWeekListGroupProvider: HabitTaskBaseListGroupProvider {
    
    var period: HabitDatePeriod?
    
    func fetchGroups(in period: HabitDatePeriod, completion: @escaping ([HabitTaskGroup]?) -> Void) {
        loadTasksIfNeeded(in: period) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }
            
            let groups = HabitPeriodItemOrganizer.groupAll(from: tasks, with: .all)
            completion(groups)
        }
    }
    
    private func loadTasksIfNeeded(in period: HabitDatePeriod,
                                   completion: @escaping ([HabitPeriodItem]?) -> Void) {
        var bRefresh: Bool = self.shouldRefresh
        if !bRefresh {
            /// 当period 不同时会强制更新
            bRefresh = (period != self.period)
        }
        
        guard bRefresh else {
            completion(self.periodItems)
            return
        }

        /// 刷新任务列表
        let requestID = requestManager.executeRequest()
        TimelyPlan.habit.fetchPeriodItems(in: period) { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(nil)
                return
            }
            
            self.period = period
            self.periodItems = tasks
            self.setNeedsRefresh(false)
            completion(self.periodItems)
        }
    }
    
}

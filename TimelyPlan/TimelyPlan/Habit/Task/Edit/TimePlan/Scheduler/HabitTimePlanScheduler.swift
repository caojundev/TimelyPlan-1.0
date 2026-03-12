//
//  HabitScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/21.
//

import Foundation

class HabitTimePlanScheduler {
    
    /// 定期重复
    private lazy var regularScheduler: HabitTimePlanRegularScheduler = {
        let scheduler = HabitTimePlanRegularScheduler()
        return scheduler
    }()
    
    /// 判断习惯在特定日期是否为计划日
    func isScheduledDate(_ date: Date,
                         timePlan: HabitTimePlan?,
                         dateRange: DateRange) -> Bool {
        /// 未设置计划，表示每天重复
        guard let timePlan = timePlan else {
            return true
        }

        guard let startDate = dateRange.startDate, dateRange.contains(date: date) else {
            return false
        }
        
        let isScheduled = regularScheduler.isScheduledDate(date,
                                                           withRule: timePlan.regularRule,
                                                           startDate: startDate)
        return isScheduled
    }
}

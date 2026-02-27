//
//  HabitScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/21.
//

import Foundation

class HabitTimePlanScheduler: HabitTimePlanRandomSchedulerDelegate {
    
    /// 定期重复
    private lazy var regularScheduler: HabitTimePlanRegularScheduler = {
        let scheduler = HabitTimePlanRegularScheduler()
        return scheduler
    }()
    
    /// 随机重复
    private lazy var randomScheduler: HabitTimePlanRandomScheduler = {
        let scheduler = HabitTimePlanRandomScheduler()
        scheduler.delegate = self
        return scheduler
    }()
    
    /// 判断习惯在特定日期是否为计划日
    func isScheduledDate(_ date: Date,
                         timePlan: HabitTimePlan?,
                         startDate: Date?,
                         endDate: Date?,
                         firstWeekday: Weekday = .sunday) -> Bool {
        /// 未设置计划，表示每天重复
        guard let timePlan = timePlan else {
            return true
        }

        /// 无开始日期时是一个无效日期范围
        guard let startDate = startDate else {
            return false
        }

        /// 在设定日期范围内
        let dateRange = DateRange(startDate: startDate, endDate: endDate)
        guard dateRange.contains(date: date) else {
            return false
        }
        
        var isScheduled = true
        if timePlan.type == .regularly {
            /// 定期重复
            isScheduled = regularScheduler.isScheduledDate(date,
                                                           withRule: timePlan.regularRule,
                                                           startDate: startDate)

        } else {
            /// 随机
            isScheduled = randomScheduler.isScheduledDate(date,
                                                          withRule: timePlan.randomRule,
                                                          firstWeekday: firstWeekday)
        }
        
        return isScheduled
    }
    
    // MARK: - HabitTimePlanRandomSchedulerDelegate
    func numberOfCompletedDays(for scheduler: HabitTimePlanRandomScheduler,
                               fromDate: Date,
                               toDate: Date) -> Int {
        return 0
    }

    func isLoggedDay(for scheduler: HabitTimePlanRandomScheduler, date: Date) -> Bool {
        return false
    }
}

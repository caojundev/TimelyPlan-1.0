//
//  HabitTimePlanRandomScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/9.
//

import Foundation

protocol HabitTimePlanRandomSchedulerDelegate: AnyObject {

    /// 在特定日期范围内任务完成天数
    func numberOfCompletedDays(for scheduler: HabitTimePlanRandomScheduler,
                                fromDate: Date,
                                toDate: Date) -> Int

    /// 判断特定日期是否为计划日
    func isLoggedDay(for scheduler: HabitTimePlanRandomScheduler, date: Date) -> Bool
}

/// 周期完成天数计划
class HabitTimePlanRandomScheduler {
    
    /// 获取完成天数代理对象
    weak var delegate: HabitTimePlanRandomSchedulerDelegate?
    
    /// 判断一个特定日期是否是计划日
    func isScheduledDate(_ date: Date,
                         withRule rule: HabitTimePlanRandomRule?,
                         firstWeekday: Weekday = .sunday) -> Bool {
        guard let rule = rule else {
            return true
        }
        
        var dateRange: DateRange
        let frequency = rule.frequency
        if frequency == .monthly {
            dateRange = date.rangeOfThisMonth()
        } else {
            dateRange = date.rangeOfThisWeek(firstWeekday: firstWeekday)
        }
        
        guard let fromDate = dateRange.startDate,
                let toDate = dateRange.endDate,
              let completedDays = delegate?.numberOfCompletedDays(for: self, fromDate: fromDate, toDate: toDate) else {
            return true
        }
        
        if completedDays < rule.days {
            return true
        }
        
        /// 完成天数已达成目标，判断日期是否为 log 日
        let isLogged = delegate?.isLoggedDay(for: self, date: date) ?? false
        return isLogged
    }
}

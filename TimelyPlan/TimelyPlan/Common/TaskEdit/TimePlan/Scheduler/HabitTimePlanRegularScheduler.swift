//
//  HabitTimePlanRegularScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/9.
//

import Foundation

/// 定期重复计划
class HabitTimePlanRegularScheduler {
    
    func isScheduledDate(_ date: Date,
                         withRule rule: HabitTimePlanRegularRule?,
                         startDate: Date) -> Bool {
        guard let rule = rule else {
            return true
        }

        let interval = rule.interval
        var isScheduled = false
        switch rule.frequency {
        case .daily:
            isScheduled = isScheduledDate(date,
                                          startDate: startDate,
                                          dayInterval: interval)
        case .weekly:
            /// 普通周模式
            isScheduled = isScheduledDate(date,
                                          startDate: startDate,
                                          weekInterval: interval,
                                          daysOfTheWeek: rule.daysOfTheWeek)
        case .monthly:
            isScheduled = isScheduledDate(date,
                                          startDate: startDate,
                                          monthInterval: interval,
                                          daysOfTheMonth: rule.daysOfTheMonth)
        default:
            isScheduled = true
        }
        
        return isScheduled
    }
    
    /// 按天重复
    private func isScheduledDate(_ date: Date,
                         startDate: Date,
                         dayInterval: Int) -> Bool {
        if date.isPreviousDay(of: startDate) {
            return false
        }
        
        let daysCount = Date.days(fromDate: startDate, toDate: date)
        return daysCount % dayInterval == 0
    }
    
    /// 按周重复
    private func isScheduledDate(_ date: Date,
                         startDate: Date,
                         weekInterval: Int,
                         daysOfTheWeek: [Weekday]?) -> Bool {
        guard let daysOfTheWeek = daysOfTheWeek else {
            return false
        }
        
        let weeksCount = Date.weeks(fromDate: startDate, toDate: date)
        if weeksCount % weekInterval != 0 {
            /// 非计划周
            return false
        }
        
        /// 判断是否是计划日
        let weekday = Weekday(date: date)
        return daysOfTheWeek.contains(weekday)
    }
    
    /// 按月重复
    private func isScheduledDate(_ date: Date,
                         startDate: Date,
                         monthInterval: Int,
                         daysOfTheMonth: [Int]?) -> Bool {
        guard let daysOfTheMonth = daysOfTheMonth else {
            return false
        }

        let monthsCount = Date.months(fromDate: startDate, toDate: date)
        if monthsCount % monthInterval != 0 {
            return false
        }
        
        if daysOfTheMonth.contains(date.day) {
            return true
        }
        
        /// 判断最后一天
        /// 包含最后一天索引并且date是当月最后一天
        if daysOfTheMonth.contains(-1) && date.isLastDayOfMonth {
            return true
        }
        
        return false
    }
}

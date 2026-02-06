//
//  Date+Compare.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/31.
//

import Foundation

extension Date {

    /// 判断当前日期是否为另一个日期之前的某一天
    /// - Parameter date: 要比较的日期
    /// - Returns: 如果当前日期是`date`之前的某一天，则返回true，否则返回false
    func isPreviousDay(of date: Date) -> Bool {
        let calendar = Calendar.current
        
        // 获取两个日期的开始时刻
        let startOfDayForSelf = calendar.startOfDay(for: self)
        let startOfDayForDate = calendar.startOfDay(for: date)
        
        // 比较两个日期的开始时刻
        return startOfDayForSelf < startOfDayForDate
    }
    
    func isFutureOrSameDay(as date: Date) -> Bool {
        return !isPreviousDay(of: date)
    }
    
    /// 是否是今日之后的天
    var isFutureDay: Bool {
        isFutureDay(of: .now)
    }
    
    /// 判断当前日期是否是特定日期之后的天
    func isFutureDay(of date: Date) -> Bool {
        let currentStartDate = date.startOfDay()
        return currentStartDate.compare(self.startOfDay()) == .orderedAscending
    }
    
    /// 是否是同一天
    func isInSameDayAs(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    /// 是否是同一周
    func isInSameWeekAs(_ date: Date, firstWeekday: Weekday) -> Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = firstWeekday.rawValue
        let components1 = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let components2 = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return components1.yearForWeekOfYear == components2.yearForWeekOfYear &&
               components1.weekOfYear == components2.weekOfYear
    }
    
    /// 是否是同一月
    func isInSameMonthAs(_ date: Date) -> Bool {
        return self.month == date.month && self.year == date.year
    }
    
    /// 是否是同一年
    func isInSameYearAs(_ date: Date) -> Bool {
        return self.year == date.year
    }
    
    /// 是否是当前月的日期
    var isInCurrentMonth: Bool {
        return isInSameMonthAs(Date())
    }
    
    /// 是否是当月最后一天
    var isLastDayOfMonth: Bool {
        return self.day == numberOfDaysInMonth()
    }
    
    /// 是否是当前年份的日期
    var isInCurrentYear: Bool {
        return isInSameYearAs(Date())
    }
    
    /// 判断当前日期是否在指定日期之前的月份
    /// - Parameter date: 要比较的日期
    /// - Returns: 如果当前日期在指定日期之前的月份，则返回 true，否则返回 false
    func isBeforeMonth(of date: Date) -> Bool {
        let calendar = Calendar.current
        
        // 获取两个日期的年份和月份
        let thisYearMonth = (calendar.component(.year, from: self), calendar.component(.month, from: self))
        let otherYearMonth = (calendar.component(.year, from: date), calendar.component(.month, from: date))
        
        // 比较年份和月份
        return thisYearMonth < otherYearMonth
    }
}

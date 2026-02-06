//
//  Date+Month.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/12.
//

import Foundation

/// 月份
enum Month: Int, CaseIterable {
    case january = 1, february, march, april, may, june, july, august, september, october, november, december
    
    var symbol: String {
        let symbols = Date.monthSymbols
        return symbols[rawValue - 1]
    }
    
    var shortSymbol: String {
        let symbols = Date.shortMonthSymbols
        return symbols[rawValue - 1]
    }
}

extension Date {

    func startOfMonth() -> Date {
        let date = firstDayOfMonth()
        return date.startOfDay()
    }

    func endOfMonth() -> Date {
        let date = lastDayOfMonth()
        return date.endOfDay()
    }
    
    /// 获取日历在该日期对应的月份的日期数目，包括当前月份以及前后两个月的日期数目，firstWeekday 参数用于指定每周的第一天是星期几
    func calendarMonthDaysCount(firstWeekday: Weekday) -> Int {
        
        /// 当前月份日期
        let currentMonthDaysCount = numberOfDaysInMonth()
        let firstDate = firstDayOfMonth()
        let lastDate = lastDayOfMonth()
        
        /// 上一个月份的天数
        let currentMonthStartWeekday = firstDate.weekday
        var previousMonthDaysCount = currentMonthStartWeekday - firstWeekday.rawValue
        if previousMonthDaysCount < 0 {
            previousMonthDaysCount += 7
        }
        
        /// 下一个月份的天数
        let currentMonthEndWeekday = lastDate.weekday
        
        /// 当月在最后一周中的天数
        var lastWeekDaysCount = currentMonthEndWeekday - firstWeekday.rawValue + 1
        if lastWeekDaysCount < 0 {
            lastWeekDaysCount += 7
        }
        
        let nextMonthDaysCount = 7 - lastWeekDaysCount
        return previousMonthDaysCount + currentMonthDaysCount + nextMonthDaysCount
    }
    
    /// 生成一个日历显示的日期数组，包括当前月份以及前后两个月的日期，firstWeekday 参数用于指定每周的第一天是星期几
    func calendarMonthDays(firstWeekday: Weekday) -> [Date] {
        let currentMonthDays = datesInMonth()
        let startDay = currentMonthDays.first!
        
        /// 获取上一个月的显示日期
        var previousMonthDays: [Date] = []
        var previousMonthDay = startDay.firstDayOfWeek(firstWeekday: firstWeekday.rawValue)
        while previousMonthDay < startDay {
            previousMonthDays.append(previousMonthDay)
            previousMonthDay = previousMonthDay.dateByAddingDays(1)!
        }
        
        /// 获取下一个月的日期
        let endDay = currentMonthDays.last!
        /// 本月最后一天所在周的最后一天日期
        let lastDayDate = endDay.lastDayOfWeek(firstWeekday: firstWeekday.rawValue)
        
        var nextMonthDays: [Date] = []
        var nextMonthDay = endDay.dateByAddingDays(1)!
        while nextMonthDay <= lastDayDate {
            nextMonthDays.append(nextMonthDay)
            nextMonthDay = nextMonthDay.dateByAddingDays(1)!
        }
        
        return previousMonthDays + currentMonthDays + nextMonthDays
    }
    
    /// 计算两个日期之间的月份数目
    static func months(fromDate: Date, toDate: Date) -> Int {
        // 计算年份差和月份差
        let yearDifference = toDate.year - fromDate.year
        let monthDifference = toDate.month - fromDate.month
        
        // 返回总的月数差
        return yearDifference * 12 + monthDifference
    }
    
    func monthsBetween(_ otherDate: Date) -> Int {
        return Date.months(fromDate: self, toDate: otherDate)
    }    
    
    /// 计算两个日期之间的间隔年数目
    static func years(fromDate: Date, toDate: Date) -> Int {
        return toDate.year - fromDate.year
    }
    
    /// 当前月份最后一天日期
    static var lastDayOfCurrentMonth: Date {
        return .now.lastDayOfMonth()
    }
    
    /// 日期所在月第一天日期
    func firstDayOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func lastDayOfMonth() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.day = numberOfDaysInMonth()
        return calendar.date(from: components)!
    }
    
    /// 获取日期所在月的天数
    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        return range.count
    }
    
    /// 获取日期所在月的周数目
    func numberOfWeeksInMonth(firstWeekday: Weekday = .sunday) -> Int {
        let dates = self.calendarMonthDays(firstWeekday: firstWeekday)
        return dates.count / DAYS_PER_WEEK
    }
    
    /// 获取日期所在月所有日期数组
    func datesInMonth() -> [Date] {
        let startDate = firstDayOfMonth()
        let daysCount = numberOfDaysInMonth()
        var dates = [startDate]
        for i in 1..<daysCount {
            let date = startDate.dateByAddingDays(i)!
            dates.append(date)
        }
        
        return dates
    }

    // MARK: - Symbols
    static var monthSymbols: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        return dateFormatter.monthSymbols
    }
    
    static func monthSymbol(ofMonth month: Int) -> String {
        let index = month - 1
        return monthSymbols[index]
    }
    
    static var shortMonthSymbols: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        return dateFormatter.shortMonthSymbols
    }
}

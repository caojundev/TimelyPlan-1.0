//
//  Date+Week.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/31.
//

import Foundation

extension Date {
    
    /// 日期所在日开始日期（00:00:00）
    func startOfWeek(firstWeekday: Weekday) -> Date {
        let date = firstDayOfWeek(firstWeekday: firstWeekday)
        return date.startOfDay()
    }

    /// 日期所在日结束日期（23:59:59）
    func endOfWeek(firstWeekday: Weekday) -> Date {
        let date = lastDayOfWeek(firstWeekday: firstWeekday)
        return date.endOfDay()
    }
    
    /// 根据当前月显示天数获取显示周数
    static func numberOfWeeksInMonth(of displayDaysCount: Int) -> Int {
        let count = displayDaysCount / DAYS_PER_WEEK + ((displayDaysCount % DAYS_PER_WEEK != 0) ? 1 : 0)
        return count
    }
    
    /// 获取当前日期在本周的索引（范围1～7，返回0表示无效结果）
    func weekIndex(firstWeekday: Weekday) -> Int {
        let weekStartDate = firstDayOfWeek(firstWeekday: firstWeekday.rawValue)
        if isInSameDayAs(weekStartDate) {
            return 1
        }
        
        for day in 1...6 {
            if let date = weekStartDate.dateByAddingDays(day), isInSameDayAs(date){
                return day + 1
            }
        }
        
        return 0
    }
    
    // 静态方法，获取指定日期所在周的第一天日期
    static func firstDayOfWeek(for date: Date, firstWeekday: Int) -> Date {
        let firstWeekday = min(7, max(1, firstWeekday))
        let currentWeekday = date.weekday
        var days = firstWeekday - currentWeekday
        if currentWeekday < firstWeekday {
            days -= 7
        }
        
        return date.dateByAddingDays(days)!
    }

    // 获取日期自身所在周的第一天日期，默认第一天为周日（firstWeekday = 1）
    func firstDayOfWeek() -> Date {
        return firstDayOfWeek(firstWeekday: Weekday.firstWeekday.rawValue)
    }
    
    // 获取当前日期所在周的第一天日期
    func firstDayOfWeek(firstWeekday: Weekday) -> Date {
        return Date.firstDayOfWeek(for: self, firstWeekday: firstWeekday.rawValue)
    }
    
    func firstDayOfWeek(firstWeekday: Int) -> Date {
        return Date.firstDayOfWeek(for: self, firstWeekday: firstWeekday)
    }

    // 获取日期自身所在周的最后一天日期，默认第一天为周日（firstWeekday = 1）
    func lastDayOfWeek() -> Date {
        return lastDayOfWeek(firstWeekday: Weekday.firstWeekday.rawValue)
    }
    
    // 获取日期所在周的最后一天日期
    func lastDayOfWeek(firstWeekday: Weekday) -> Date {
        return lastDayOfWeek(firstWeekday: firstWeekday.rawValue)
    }
    
    func lastDayOfWeek(firstWeekday: Int) -> Date {
        let firstDate = firstDayOfWeek(firstWeekday: firstWeekday)
        return firstDate.dateByAddingDays(6)!
    }
    
    // MARK: - 日期数组
    // 获取最近七天日期（包含今日）
    func latestSevenDays() -> [Date] {
        let startDate = self.startOfDay()
        var dates: [Date] = []
        for day in 0...6 {
            if let date = startDate.dateByAddingDays(-day) {
                dates.insert(date, at: 0)
            }
        }
        
        return dates
    }
    
    /// 获取当前周日期数组
    func thisWeekDays() -> [Date] {
        return thisWeekDays(firstWeekday: Weekday.firstWeekday.rawValue)
    }
    
    /// 获取当前周日期数组
    /// - Parameter firstWeekday: 周第一天索引
    /// - Returns: 周日期数组
    func thisWeekDays(firstWeekday: Weekday) -> [Date] {
        return thisWeekDays(firstWeekday: firstWeekday.rawValue)
    }
    
    func thisWeekDays(firstWeekday: Int) -> [Date] {
        let firstWeekDate = firstDayOfWeek(firstWeekday: firstWeekday)
        let startDate = firstWeekDate.startOfDay()
        var dates = [startDate]
        for day in 1...6 {
            if let date = startDate.dateByAddingDays(day) {
                dates.append(date)
            }
        }
        
        return dates
    }

    /// 计算两个日期之间的周数
    static func weeks(fromDate: Date, toDate: Date, firstWeekday: Weekday = .sunday) -> Int {
        let from = fromDate.firstDayOfWeek(firstWeekday: firstWeekday.rawValue)
        let to = toDate.firstDayOfWeek(firstWeekday: firstWeekday.rawValue)
        let count = days(fromDate: from, toDate: to)
        return count / DAYS_PER_WEEK
    }
    
    func weeksBetween(_ otherDate: Date) -> Int {
        return Date.weeks(fromDate: self, toDate: otherDate)
    }
}

// MARK: - 符号
extension Date {
    
    /// 获取Weekday对应的特定样式的符号
    static func weekdaySymbol(style: WeekdaySymbolStyle, weekday: Weekday) -> String {
        let symbols = Date.weekdaySymbols(style: style, firstWeekday: 1)
        return symbols[weekday.rawValue - 1]
    }
    
    /// 根据样式和周开始日返回一周符号数组
    static func weekdaySymbols(style: WeekdaySymbolStyle, firstWeekday: Int) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        var symbols: [String]
        switch style {
        case .full:
            symbols = dateFormatter.weekdaySymbols
        case .short:
            symbols = dateFormatter.shortWeekdaySymbols
        case .veryShort:
            symbols = dateFormatter.veryShortWeekdaySymbols
        }
    
        let firstWeekday = max(1, min(firstWeekday, 7))
        let index = firstWeekday - 1
        if index > 0 {
            let prefixSymbols = Array(symbols[index..<7])
            let suffixSymbols = Array(symbols[0..<index])
            return prefixSymbols + suffixSymbols
        }
        
        return symbols
    }
    
    // MARK: - 周符号
    static func weekdaySymbols() -> [String] {
        let firstWeekday = Calendar.current.firstWeekday
        return weekdaySymbols(firstWeekday: firstWeekday)
    }
    
    static func weekdaySymbols(firstWeekday: Int) -> [String] {
        return weekdaySymbols(style: .full, firstWeekday: firstWeekday)
    }
    
    // MARK: - 短周符号
    static func shortWeekdaySymbols() -> [String] {
        let firstWeekday = Calendar.current.firstWeekday
        return shortWeekdaySymbols(firstWeekday: firstWeekday)
    }
    
    static func shortWeekdaySymbols(firstWeekday: Int) -> [String] {
        return weekdaySymbols(style: .short, firstWeekday: firstWeekday)
    }
    
    // MARK: - 超短周符号
    static func veryShortWeekdaySymbols() -> [String] {
        let firstWeekday = Calendar.current.firstWeekday
        return veryShortWeekdaySymbols(firstWeekday: firstWeekday)
    }
    
    static func veryShortWeekdaySymbols(firstWeekday: Int) -> [String] {
        return weekdaySymbols(style: .veryShort, firstWeekday: firstWeekday)
    }
    
    // MARK: - 实例方法
    func weekdaySymbol(style: WeekdaySymbolStyle) -> String {
        let symbols = Date.weekdaySymbols(style: style, firstWeekday: 1)
        return symbols[weekday - 1]
    }
    
    func weekdaySymbol() -> String {
        return weekdaySymbol(style: .full)
    }
    
    func shortWeekdaySymbol() -> String {
        return weekdaySymbol(style: .short)
    }
    
    func veryShortWeekdaySymbol() -> String {
        return weekdaySymbol(style: .veryShort)
    }
}
    
    
    

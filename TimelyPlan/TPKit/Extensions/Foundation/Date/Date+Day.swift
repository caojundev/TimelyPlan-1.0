//
//  Date+Days.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/31.
//

import Foundation

extension Date {
    
    /// 今日开始日期
    static var startOfToday: Date {
        return Date().startOfDay()
    }
    
    /// 日期所在日开始日期（00:00:00）
    func startOfDay() -> Date {
        let unitFlags: Set<Calendar.Component> = [.year, .month, .day]
        let calendar = Calendar.current
        let components = calendar.dateComponents(unitFlags, from: self)
        let date = calendar.date(from: components)!
        return date
    }

    /// 日期所在日结束日期（23:59:59）
    func endOfDay() -> Date {
        let unitFlags: Set<Calendar.Component> = [.year, .month, .day]
        let calendar = Calendar.current
        var components = calendar.dateComponents(unitFlags, from: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        components.nanosecond = 59
        let date = calendar.date(from: components)!
        return date
    }
    
    /// 计算两个日期之间的天数
    static func days(fromDate: Date, toDate: Date) -> Int {
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: fromDate)
        let toDate = calendar.startOfDay(for: toDate)
        let components = calendar.dateComponents([.day], from: fromDate, to: toDate)
        return components.day ?? 0
    }
    
    func daysBetween(_ otherDate: Date) -> Int {
        return Date.days(fromDate: self, toDate: otherDate)
    }
}

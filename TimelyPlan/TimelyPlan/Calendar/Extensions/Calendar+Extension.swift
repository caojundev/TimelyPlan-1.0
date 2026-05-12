//
//  Calendar+Extension.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/12.
//

import Foundation

extension Calendar {
    
    /// 使用自定义周起始日计算指定日期的周数
    static func weekNumber(for date: Date, firstWeekday: Weekday) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = firstWeekday.rawValue
        calendar.minimumDaysInFirstWeek = 1
        return calendar.component(.weekOfYear, from: date)
    }
}

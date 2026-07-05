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

extension Calendar {
    /// 获取指定年月的 DateInterval
    /// - Parameters:
    ///   - year: 年份
    ///   - month: 月份
    /// - Returns: 该月的 DateInterval，start 为当月1日 00:00:00，end 为当月最后一天 23:59:59
    func monthInterval(year: Int, month: Int) -> DateInterval? {
        var startComponents = DateComponents(year: year, month: month, day: 1)
        startComponents.hour = 0
        startComponents.minute = 0
        startComponents.second = 0
        
        guard let startDate = self.date(from: startComponents) else { return nil }
        
        // 获取该月天数
        guard let range = self.range(of: .day, in: .month, for: startDate) else { return nil }
        let lastDay = range.count
        
        var endComponents = DateComponents(year: year, month: month, day: lastDay)
        endComponents.hour = 23
        endComponents.minute = 59
        endComponents.second = 59
        endComponents.nanosecond = 59
        guard let endDate = self.date(from: endComponents) else { return nil }
        
        return DateInterval(start: startDate, end: endDate)
    }
}

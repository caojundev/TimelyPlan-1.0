//
//  DateInterval+Calendar.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

extension DateInterval {
    
    /// 替换天日期
    mutating func replacingDay(with dayDate: Date) {
        let duration = self.duration
        self.start = self.start.dateByReplacingDay(with: dayDate)
        self.end = self.start.addingTimeInterval(duration)
    }
    
    static func rangeOfDay(_ date: Date) -> DateInterval  {
        let start = date.startOfDay()
        let end = start.dateByAddingHours(HOURS_PER_DAY)!
        return DateInterval(start: start, end: end)
    }
    
    static func rangeOfWeek(weekStartDate: Date) -> DateInterval {
        let weekEndDate = weekStartDate.dateByAddingDays(6)!
        let range = DateInterval(start: weekStartDate.startOfDay(),
                                 end: weekEndDate.endOfDay())
        return range
    }
    
    static func range(with firstDate: Date, mode: CalendarPageMode) -> DateInterval {
        let addingDays = mode.days - 1
        let start = firstDate.startOfDay()
        let end = start.dateByAddingDays(addingDays)!.endOfDay()
        let range = DateInterval(start: start, end: end)
        return range
    }
}

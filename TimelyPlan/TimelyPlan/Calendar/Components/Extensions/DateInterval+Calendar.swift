//
//  DateInterval+Calendar.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

extension DateInterval {
    
    /// 遍历区间内每一天，返回 false 可随时停止
    func enumerateDays(using calendar: Calendar = .current,
                       _ handler: (Date) -> Bool) {
        var currentDate = calendar.startOfDay(for: start)
        let endDate = calendar.startOfDay(for: end)
        
        while currentDate <= endDate {
            let shouldContinue = handler(currentDate)
            if !shouldContinue {
                break
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
    }
    
    /// 任务日期信息
    var dateInfo: TaskDateInfo {
        return TaskDateInfo(startDate: start, endDate: end, isAllDay: false)
    }
    
    /// 无限的日期范围
    static var infiniteInterval: DateInterval {
        return DateInterval(start: .distantPast, end: .distantFuture)
    }

    /// 替换天日期
    mutating func replacingDay(with dayDate: Date) {
        let duration = self.duration
        self.start = self.start.dateByReplacingDay(with: dayDate)
        self.end = self.start.addingTimeInterval(duration)
    }
    
    /// 时间线范围 00:00 ~ 00:00
    static func timelineRangeOfDay(_ date: Date) -> DateInterval  {
        let start = date.startOfDay()
        let end = start.dateByAddingHours(HOURS_PER_DAY)!
        return DateInterval(start: start, end: end)
    }
    
    /// 时间线范围 00:00 ~ 23:59:59
    static func rangeOfDay(_ date: Date) -> DateInterval  {
        let start = date.startOfDay()
        let end = date.endOfDay()
        return DateInterval(start: start, end: end)
    }
    
    static func rangeOfMonth(containing date: Date) -> DateInterval  {
        let start = date.startOfMonth()
        let end = date.endOfMonth()
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

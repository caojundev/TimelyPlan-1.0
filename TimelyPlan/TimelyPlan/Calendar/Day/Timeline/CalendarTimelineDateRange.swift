//
//  CalendarTimelineDateRange.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/6.
//

import Foundation

struct CalendarTimelineDateRange {
    
    /// 时间线开始日期
    var start: Date
    
    /// 时间线结束日期
    var end: Date
    
    /// 结束与开始事件间隔
    var interval: TimeInterval {
        return end.timeIntervalSince(start)
    }
    
    init(date: Date) {
        let start = date.startOfDay()
        self.start = start
        self.end = start.dateByAddingHours(HOURS_PER_DAY)!
    }
    
}

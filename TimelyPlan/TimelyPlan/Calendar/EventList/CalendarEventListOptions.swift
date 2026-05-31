//
//  CalendarEventListOptions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/31.
//

import Foundation

struct CalendarEventListOptions {
    
    /// 显示日期
    let date: Date
    
    /// 日期范围
    var dateRange: DateInterval {
        return .range(with: date, mode: .day)
    }
}

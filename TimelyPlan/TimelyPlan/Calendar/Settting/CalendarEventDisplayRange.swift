//
//  CalendarEventDisplayRange.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/1.
//

import Foundation

/// 日历中习惯任务的显示范围
enum CalendarEventDisplayRange: String, Codable, TPMenuRepresentable {
    case todayOnly
    case next3Days
    case next7Days
    case next30Days

    var title: String {
        switch self {
        case .todayOnly:
            return resGetString("Today Only")
        case .next3Days:
            return resGetString("Next 3 Days")
        case .next7Days:
            return resGetString("Next 7 Days")
        case .next30Days:
            return resGetString("Next 30 Days")
        }
    }
    
    /// 对应的天数偏移量（从今天起算），方便业务层直接计算日期范围
    var dayOffset: Int {
        switch self {
        case .todayOnly:  return 0
        case .next3Days:  return 3
        case .next7Days:  return 7
        case .next30Days: return 30
        }
    }
    
    var interval: DateInterval {
        let start = Date().startOfDay()
        var end = start.dateByAddingDays(dayOffset) ?? start
        end = end.endOfDay()
        return DateInterval(start: start, end: end)
    }

}

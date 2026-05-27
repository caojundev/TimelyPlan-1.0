//
//  TodoStatsDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/27.
//

import Foundation

/// 统计周期
enum StatisticsPeriod {
    case week(Date, Weekday) // 关联任意一天，定位到该周
    case month(Date)   // 关联任意一天，定位到该月
    case year(Date)    // 关联任意一天，定位到该年
    
    var date: Date {
        switch self {
        case .week(let date, _), .month(let date), .year(let date):
            return date
        }
    }
    
    func dateRange() -> DateRange {
        switch self {
        case .week(let date, let firstWeekday):
            return date.rangeOfThisWeek(firstWeekday: firstWeekday)
        case .month(let date):
            return date.rangeOfThisMonth()
        case .year(let date):
            return date.rangeOfThisYear()
        }
    }
}

struct TodoStatsDataItem {

    /// 统计周期
    var period: StatisticsPeriod
    
    /// 周期内任务数组
    var tasks: [TodoTask]?
}

//
//  WSCalendarEventBarRange.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation

/// 事项条组件的显示范围。
///
/// 各组件共用同一套视图与交互器，只有显示范围的起点与天数不同：
/// `.days` 从今天开始显示若干天，`.week` 显示今天所在的一周。
enum WSCalendarEventBarRange {

    /// 从今天开始显示若干天
    case days(Int)

    /// 显示今天所在的一周。周起始日取自日历设置
    case week

    /// 显示的天数
    var dayCount: Int {
        switch self {
        case .days(let dayCount):
            return max(1, dayCount)
        case .week:
            return DAYS_PER_WEEK
        }
    }

    /// 指定日期对应的显示第一天
    func startDate(for date: Date = Date()) -> Date {
        switch self {
        case .days:
            return date.startOfDay()
        case .week:
            return date.firstDayOfWeek(firstWeekday: CalendarSetting.shared.firstWeekday).startOfDay()
        }
    }

    /// 指定日期对应的显示范围
    func interval(for date: Date = Date()) -> DateInterval {
        return .rangeOfDays(firstDate: startDate(for: date), dayCount: dayCount)
    }
}

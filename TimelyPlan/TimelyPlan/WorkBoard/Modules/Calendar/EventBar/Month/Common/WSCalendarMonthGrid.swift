//
//  WSCalendarMonthGrid.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation

/// 月份网格：当月 1 号所在周的首日，以及需要在日历中占用的周数。
///
/// 周数按「前置天数 + 当月天数」算出，并收敛到 5~6 行，与月历的展示行数一致。
struct WSCalendarMonthGrid {

    /// 网格第一天（当月 1 号所在周的首日）
    let startDate: Date

    /// 当月第一天
    let monthStart: Date

    /// 下月第一天（不含）
    let monthEnd: Date

    /// 网格行数（周数）
    let weekCount: Int

    init(monthDate: Date, firstWeekday: Weekday = CalendarSetting.shared.firstWeekday) {
        let monthStart = monthDate.startOfMonth()
        let startDate = monthStart.firstDayOfWeek(firstWeekday: firstWeekday).startOfDay()
        let leadingDays = max(Date.days(fromDate: startDate, toDate: monthStart), 0)
        let totalDays = leadingDays + monthStart.numberOfDaysInMonth()
        let weeks = Int(ceil(Double(totalDays) / Double(DAYS_PER_WEEK)))

        self.startDate = startDate
        self.monthStart = monthStart
        self.monthEnd = monthStart.dateByAddingMonths(1)?.startOfMonth() ?? monthStart.endOfMonth()
        self.weekCount = min(max(weeks, 5), 6)
    }

    /// 第 `index` 周的第一天
    func weekStartDate(at index: Int) -> Date? {
        return startDate.dateByAddingDays(index * DAYS_PER_WEEK)
    }

    /// 第 `index` 周内属于当月的日期。首行与末行的日期数可能少于 7 天
    func days(inWeek index: Int) -> [Date] {
        guard let weekStartDate = weekStartDate(at: index) else {
            return []
        }

        return (0..<DAYS_PER_WEEK).compactMap { offset in
            guard let date = weekStartDate.dateByAddingDays(offset),
                  date >= monthStart, date < monthEnd else {
                return nil
            }

            return date
        }
    }
}

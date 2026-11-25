//
//  WSCalendarDayEventsDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation

/// 日历事项列表的数据：把一段时间内的事项按天分组。
///
/// 只负责分组，不计算任何展示文案；日期头与行详情由各尺寸的列表视图按需生成。
/// 供 `WSCalendarEventListView` 直接消费，各尺寸的「今日 / 最近事项」列表共用同一份数据形态。
struct WSCalendarDayEventsDataItem: WSPluginDataItem {

    /// 一天的事项
    struct Day {

        /// 当天零点
        let date: Date

        /// 当天展示的事项，已排序
        let events: [CalendarEvent]
    }

    /// 只包含有事项的天，按日期升序排列
    let days: [Day]

    init(days: [Day]) {
        self.days = days
    }

    /// 把事项按天分组。跨天事项会出现在它覆盖的每一天。
    /// - Parameters:
    ///   - events: 已经限定在列表时间范围内的事项
    ///   - date: 列表起始日期
    ///   - dayCount: 列表覆盖的天数
    init(events: [CalendarEvent], startingAt date: Date = Date(), dayCount: Int = 7) {
        let range = DateInterval.rangeOfDays(firstDate: date, dayCount: dayCount)
        var days: [Day] = []

        range.enumerateDays { dayDate in
            let dayEnd = dayDate.endOfDay()
            let eventsInDay = events.filter { $0.startDate <= dayEnd && $0.endDate > dayDate }
            guard !eventsInDay.isEmpty else {
                return true
            }

            days.append(Day(date: dayDate, events: eventsInDay.orderedEvents))
            return true
        }

        self.days = days
    }
}

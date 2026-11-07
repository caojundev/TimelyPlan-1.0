//
//  WSCalendarDayEventsDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation

/// 日历事项列表的数据：把一段时间内的事项按天分组。
///
/// 供 `WSCalendarEventListView` 直接消费，各尺寸的「今日 / 最近事项」列表共用同一份数据形态。
struct WSCalendarDayEventsDataItem: WSPluginDataItem {

    /// 一天的事项
    struct Day {

        /// 当天零点
        let date: Date

        /// 当天要展示的事项行
        let items: [WSCalendarEventRowItem]

        /// 日期头文案
        let title: String
    }

    /// 只包含有事项的天，按日期升序排列
    let days: [Day]

    init(days: [Day]) {
        self.days = days
    }

    /// 把事项按天分组。跨天事项在每一天各生成一行，时间只展示落在该天内的部分。
    /// - Parameters:
    ///   - events: 已经限定在列表时间范围内的事项
    ///   - date: 列表起始日期
    ///   - dayCount: 列表覆盖的天数
    init(events: [CalendarEvent], startingAt date: Date = Date(), dayCount: Int = 7) {
        let range = DateInterval.rangeOfDays(firstDate: date, dayCount: dayCount)
        var days: [Day] = []

        range.enumerateDays { dayDate in
            guard let day = Self.makeDay(events: events, dayDate: dayDate) else {
                return true
            }

            days.append(day)
            return true
        }

        self.days = days
    }

    // MARK: - 分组
    /// 生成某一天的展示数据，当天没有事项时返回 nil
    private static func makeDay(events: [CalendarEvent], dayDate: Date) -> Day? {
        let dayEnd = dayDate.endOfDay()
        let eventsInDay = events.filter { $0.startDate <= dayEnd && $0.endDate > dayDate }
        guard !eventsInDay.isEmpty else {
            return nil
        }

        let items = eventsInDay.orderedEvents.map { event -> WSCalendarEventRowItem in
            return WSCalendarEventRowItem(event: event,
                                          timeText: timeText(for: event, in: dayDate))
        }

        return Day(date: dayDate, items: items, title: title(for: dayDate))
    }

    // MARK: - 文案
    /// 事项在某一天的时段文案，跨天事项截取当天部分
    private static func timeText(for event: CalendarEvent, in dayDate: Date) -> String {
        guard !event.isAllDay else {
            return resGetString("All day")
        }

        let start = max(event.startDate, dayDate)
        let end = min(event.endDate, dayDate.endOfDay())
        return "\(start.timeString) - \(end.timeString)"
    }

    /// 日期头文案：今天与明天用相对日期，其余日期展示月日与星期
    private static func title(for dayDate: Date) -> String {
        if dayDate.isToday {
            return resGetString("Today")
        }

        if dayDate.isTomorrow {
            return resGetString("Tomorrow")
        }

        return dayDate.monthDayShortWeekdaySymbolString
    }
}

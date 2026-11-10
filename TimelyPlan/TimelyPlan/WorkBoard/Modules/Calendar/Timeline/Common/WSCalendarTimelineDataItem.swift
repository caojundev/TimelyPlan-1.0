//
//  WSCalendarTimelineDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation

// MARK: - 展示范围

/// 时间线组件的展示范围：当前整点起若干个小时，小时数由组件尺寸决定。
///
/// 起始小时上限为 `24 - hourCount`，保证结束不超过 00:00；跨天由调用方按日期范围处理。
enum WSCalendarTimelineRange {

    /// 结束不超过 00:00 时允许的最大起始小时
    static func maximumStartHour(hourCount: Int) -> Int {
        return max(24 - hourCount, 0)
    }

    /// 指定时间所在整点，超过上限时取上限
    static func startHour(at date: Date = Date(), hourCount: Int) -> Int {
        return min(max(date.hour, 0), maximumStartHour(hourCount: hourCount))
    }

    /// 指定时间对应的展示范围
    static func interval(at date: Date = Date(), hourCount: Int) -> DateInterval {
        let startOfDay = date.startOfDay()
        let start = startOfDay.dateByAddingHours(startHour(at: date, hourCount: hourCount)) ?? startOfDay
        let end = start.dateByAddingHours(hourCount) ?? start
        return DateInterval(start: start, end: end)
    }
}

// MARK: - 组件数据

/// 时间线组件的数据：展示范围与范围内的事项。
struct WSCalendarTimelineDataItem: WSPluginDataItem {

    /// 展示范围的第一天
    let date: Date

    /// 起始小时
    let startHour: Int

    /// 结束小时
    let endHour: Int

    /// 范围内的事项
    let events: [CalendarEvent]

    init(events: [CalendarEvent] = [], at date: Date = Date(), hourCount: Int) {
        let startHour = WSCalendarTimelineRange.startHour(at: date, hourCount: hourCount)
        self.date = date.startOfDay()
        self.startHour = startHour
        self.endHour = startHour + hourCount
        self.events = events
    }
}

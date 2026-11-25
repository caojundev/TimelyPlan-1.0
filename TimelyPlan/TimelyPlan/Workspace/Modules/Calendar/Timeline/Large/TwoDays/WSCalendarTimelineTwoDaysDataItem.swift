//
//  WSCalendarTimelineTwoDaysDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation

/// 两天时间线组件的数据：今天与明天各一份时间线数据。
struct WSCalendarTimelineTwoDaysDataItem: WSPluginDataItem {

    /// 明天时间线的固定起始小时
    static let tomorrowStartHour = 9

    /// 明天时间线的固定结束小时
    static let tomorrowEndHour = 16

    /// 今天（左侧），范围内的事项
    let today: WSCalendarTimelineDataItem

    /// 明天（右侧），固定 09:00 ~ 16:00
    let tomorrow: WSCalendarTimelineDataItem

    init(events: [CalendarEvent] = [], at date: Date = Date(), todayHourCount: Int) {
        let todayInterval = WSCalendarTimelineRange.interval(at: date, hourCount: todayHourCount)
        let tomorrowInterval = Self.tomorrowInterval(at: date)
        let tomorrowDate = date.startOfDay().dateByAddingDays(1) ?? date.startOfDay()

        self.today = WSCalendarTimelineDataItem(events: Self.events(events, in: todayInterval),
                                                at: date,
                                                hourCount: todayHourCount)
        self.tomorrow = WSCalendarTimelineDataItem(date: tomorrowDate,
                                                   startHour: Self.tomorrowStartHour,
                                                   endHour: Self.tomorrowEndHour,
                                                   events: Self.events(events, in: tomorrowInterval))
    }

    /// 明天时间线覆盖的时间范围
    static func tomorrowInterval(at date: Date = Date()) -> DateInterval {
        let today = date.startOfDay()
        let tomorrow = today.dateByAddingDays(1) ?? today
        let start = tomorrow.dateByAddingHours(tomorrowStartHour) ?? tomorrow
        let end = tomorrow.dateByAddingHours(tomorrowEndHour) ?? start
        return DateInterval(start: start, end: end)
    }

    /// 只保留与时间范围有交集的事项
    private static func events(_ events: [CalendarEvent], in interval: DateInterval) -> [CalendarEvent] {
        return events.filter { $0.dateRange.intersects(interval) }
    }
}

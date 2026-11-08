//
//  WSCalendarTwoDaysDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation

// MARK: - 单天事项

/// 今明两天中单天的事项
struct WSCalendarTwoDaysDay {

    /// 当天零点
    let date: Date

    /// 当天展示的事项，已排序
    let events: [CalendarEvent]

    /// 当天的事项总数
    var totalCount: Int {
        return events.count
    }
}

// MARK: - 组件数据

/// 今明两天组件的数据：一次性取两天的数据后按天分组
class WSCalendarTwoDaysDataItem: NSObject, WSPluginDataItem {

    /// 今天
    let today: WSCalendarTwoDaysDay

    /// 明天
    let tomorrow: WSCalendarTwoDaysDay

    /// 两天合计的事项总数
    var totalCount: Int {
        return today.totalCount + tomorrow.totalCount
    }

    init(today: WSCalendarTwoDaysDay, tomorrow: WSCalendarTwoDaysDay) {
        self.today = today
        self.tomorrow = tomorrow
        super.init()
    }

    /// 把已经取到的两天事项按天分组。跨天事项会出现在它覆盖的每一天
    convenience init(events: [CalendarEvent], startingAt date: Date = Date()) {
        let todayDate = date.startOfDay()
        let tomorrowDate = todayDate.dateByAddingDays(1) ?? todayDate
        self.init(today: Self.makeDay(events: events, date: todayDate),
                  tomorrow: Self.makeDay(events: events, date: tomorrowDate))
    }

    private static func makeDay(events: [CalendarEvent], date: Date) -> WSCalendarTwoDaysDay {
        let dayEnd = date.endOfDay()
        let eventsInDay = events.filter { $0.startDate <= dayEnd && $0.endDate > date }
        return WSCalendarTwoDaysDay(date: date, events: eventsInDay.orderedEvents)
    }
}

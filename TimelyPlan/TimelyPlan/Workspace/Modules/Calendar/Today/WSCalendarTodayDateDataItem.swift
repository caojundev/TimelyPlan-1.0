//
//  WSCalendarTodayDateDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation

/// 日历·小·今日日期的数据条目。日期组件与事项数目组件共用同一份今日数据。
struct WSCalendarTodayDateDataItem: WSPluginDataItem {

    let date: Date

    /// 今日事项数目，仅事项数目组件使用，其余组件为 nil
    let eventCount: Int?

    init(date: Date, eventCount: Int? = nil) {
        self.date = date
        self.eventCount = eventCount
    }

    var monthText: String {
        return Date.monthSymbol(ofMonth: date.month)
    }

    var dayText: String {
        return "\(date.day)"
    }

    var weekdayText: String {
        return date.weekdaySymbol()
    }

    /// 今日事项数目文案，没有数目时为 nil
    var eventCountText: String? {
        guard let eventCount = eventCount else {
            return nil
        }

        return String(format: resGetString("%ld Events"), eventCount)
    }
}

//
//  WSCalendarTodayDateDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation

/// 日历·小·今日日期的数据条目。两款日期组件共用同一份今日数据。
struct WSCalendarTodayDateDataItem: WSPluginDataItem {

    let date: Date

    var monthText: String {
        return Date.monthSymbol(ofMonth: date.month)
    }

    var dayText: String {
        return "\(date.day)"
    }

    var weekdayText: String {
        return date.weekdaySymbol()
    }
}

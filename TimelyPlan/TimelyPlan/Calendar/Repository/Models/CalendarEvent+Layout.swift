//
//  CalendarEvent+Layout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/17.
//

import Foundation

// MARK: - 布局
extension CalendarEvent {

    /// 展示用结束时间。
    ///
    /// 结束时间正好落在零点时（如 2 日 18:00 至 3 日 00:00），说明只到前一天，不应再占用后一天。
    var displayEndDate: Date {
        guard endDate > startDate, endDate.isStartOfDay else {
            return endDate
        }

        return endDate.addingTimeInterval(-1)
    }

    /// 根据开始日期和布局持续天数，获取事件对应的位置
    func position(firstDate: Date, days: Int = DAYS_PER_WEEK) -> CalendarEventPosition? {
        var column = Date.days(fromDate: firstDate, toDate: startDate)
        var length = Date.days(fromDate: startDate, toDate: displayEndDate)
        if length < 0 || column >= days || column + length < 0 {
            return nil
        }
        
        let maxLength = days - 1
        if column < 0 {
            length = min(column + length, maxLength)
            column = 0
        } else {
            if column + length > maxLength {
                length = maxLength - column
            }
        }
        
        return CalendarEventPosition(column: column, length: length)
    }
}

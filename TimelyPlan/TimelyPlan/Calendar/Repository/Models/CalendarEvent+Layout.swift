//
//  CalendarEvent+Layout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/17.
//

import Foundation

// MARK: - 布局
extension CalendarEvent {
    
    /// 根据开始日期和布局持续天数，获取事件对应的位置
    func position(firstDate: Date, days: Int = DAYS_PER_WEEK) -> CalendarEventPosition? {
        var column = Date.days(fromDate: firstDate, toDate: startDate)
        var length = Date.days(fromDate: startDate, toDate: endDate)
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

//
//  DateRange+Habit.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/1.
//

import Foundation

extension DateRange {
    
    mutating func setHabitDate(_ date: Date?, for editType: DateRangeEditType) {
        if editType == .start {
            self.startDate = date?.startOfDay()
            if let date = date, let endDate = endDate, date > endDate {
                /// 开始日期大于结束日期，结束日期置为开始日期
                self.endDate = date.endOfDay()
            }
        } else {
            self.endDate = date?.endOfDay()
            if let date = date, let startDate = startDate, date < startDate {
                /// 开始日期大于结束日期，开始日期置为结束日期
                self.startDate = date.startOfDay()
            }
        }
    }
    
}

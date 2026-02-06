//
//  RepeatDayOfWeek+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/24.
//

import Foundation

extension Array where Element == RepeatDayOfWeek {
    
    /// 获取对应的Weekday数组
    var weekdays: [Weekday]? {
        var weekdaySet: Set<Weekday> = []
        for repeatDay in self {
            weekdaySet.insert(repeatDay.dayOfTheWeek)
        }
        
        if weekdaySet.count == 0 {
            return nil
        }
        
        let weekdays = weekdaySet.map { $0 }
        return weekdays
    }
}

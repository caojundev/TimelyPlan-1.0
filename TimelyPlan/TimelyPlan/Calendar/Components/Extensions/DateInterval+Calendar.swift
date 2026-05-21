//
//  DateInterval+Calendar.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

extension DateInterval {
    
    static func weekRange(of weekStartDate: Date) -> DateInterval {
        let weekEndDate = weekStartDate.dateByAddingDays(6)!
        let range = DateInterval(start: weekStartDate.startOfDay(),
                                 end: weekEndDate.endOfDay())
        return range
    }
    
    static func range(with firstDate: Date, mode: CalendarPageMode) -> DateInterval {
        let addingDays = mode.days - 1
        let start = firstDate.startOfDay()
        let end = start.dateByAddingDays(addingDays)!.endOfDay()
        let range = DateInterval(start: start, end: end)
        return range
    }
}

//
//  CalendarWeekEventsProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/11.
//

import Foundation

class CalendarWeekEventsProvider: CalendarEventsProvider {
    
    func loadEvents(weekStartDate: Date) {
        var weekEndDate = weekStartDate.dateByAddingDays(6)!
        weekEndDate = weekEndDate.endOfDay()
        let dateRange = DateRange(startDate: weekStartDate, endDate: weekEndDate)
        loadEvents(in: dateRange)
    }
}


//
//  CalendarDayEventsProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/9.
//

import Foundation

class CalendarDayEventsProvider: CalendarEventsProvider {

    func loadEvents(on date: Date) {
        let dateRange = date.rangeOfThisDay()
        loadEvents(in: dateRange)
    }
}

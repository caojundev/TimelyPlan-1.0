//
//  CalendarSystemEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation

class CalendarSystemEventProvider: CalendarEventProvider {
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        CalendarSystemManager.shared.fetchVisbleCalendarEvents(from: range.start,
                                                               to: range.end) { results in
            completion(results.toCalendarEvents())
        }
    }
}

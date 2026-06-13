//
//  CalendarSystemEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation

class CalendarSystemEventProvider: CalendarEventProvider,
                                    CalendarSystemManagerDelegate {
    
    /// 事项改变代理
    weak var delegate: CalendarEventChangeDelegate?

    init() {
        CalendarSystemManager.shared.addDelegate(self)
    }
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        CalendarSystemManager.shared.fetchVisbleCalendarEvents(from: range.start,
                                                               to: range.end) { results in
            completion(results.toCalendarEvents())
        }
    }
    
    // MARK: - CalendarSystemManagerDelegate
    func calendarSystemManagerDidUpdate(_ manager: CalendarSystemManager) {
        delegate?.calendarEventsDidChange(in: [.infiniteInterval])
    }
}

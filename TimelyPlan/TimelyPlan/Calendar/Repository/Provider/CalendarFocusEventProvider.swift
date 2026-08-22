//
//  CalendarFocusEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/22.
//

import Foundation

class CalendarFocusEventProvider: CalendarEventProvider {
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        guard CalendarSetting.shared.showFocus else {
            completion(nil)
            return
        }
        
        let interval = CalendarSetting.shared.focusDisplayRange.interval
        guard let displayRange = interval.intersection(with: range) else {
            completion(nil)
            return
        }
        
        FocusRepository.fetchMyDayEventTimers(in: range) { timers in
            guard let timers = timers else {
                completion(nil)
                return
            }

            let events = timers.toCalendarEvents(in: displayRange)
            completion(events)
        }
    }
}

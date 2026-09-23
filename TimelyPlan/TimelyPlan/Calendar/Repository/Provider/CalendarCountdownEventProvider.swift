//
//  CalendarCountdownEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/23.
//

import Foundation

class CalendarCountdownEventProvider: CalendarEventProvider {
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        guard CalendarSetting.shared.showInCountdown else {
            completion(nil)
            return
        }
        
        CountdownRepository.fetchActiveEvents { events in
            guard let events = events, events.count > 0 else {
                completion(nil)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let calendarEvents = events.toCalendarEvents(in: range)
                DispatchQueue.main.async {
                    completion(calendarEvents)
                }
            }
        }
    }
}

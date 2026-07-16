//
//  CalendarHabitEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/30.
//

import Foundation

class CalendarHabitEventProvider: CalendarEventProvider {
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        guard CalendarSetting.shared.showHabit else {
            completion(nil)
            return
        }
        
        let interval = CalendarSetting.shared.habitDisplayRange.interval
        guard let displayRange = interval.intersection(with: range) else {
            completion(nil)
            return
        }
        
        HabitRepository.fetchCalendarEventTasks(in: displayRange) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let events = tasks.toCalendarEvents(in: displayRange)
                DispatchQueue.main.async {
                    completion(events)
                }
            }
        }
    }
}

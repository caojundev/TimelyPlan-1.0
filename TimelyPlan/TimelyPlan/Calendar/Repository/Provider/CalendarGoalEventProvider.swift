//
//  CalendarGoalEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/10.
//

import Foundation

class CalendarGoalEventProvider: CalendarEventProvider {
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        guard CalendarSetting.shared.showGoal else {
            completion(nil)
            return
        }
        
        
        let interval = CalendarSetting.shared.goalDisplayRange.interval
        guard let displayRange = interval.intersection(with: range) else {
            completion(nil)
            return
        }
        
        GoalRepository.fetchCalendarEventGoalTasks(in: displayRange) { tasks in
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

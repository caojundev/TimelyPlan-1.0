//
//  HabitRangeEventColorInfoFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/12.
//

import Foundation

class HabitRangeEventColorInfoFetcher: CalendarRangeEventsProvider {
    
    private let changeObserver = CalendarEventChangeObserver(sources: [.habit])
    
    func fetchRangeEventsInfo(in range: DateInterval, completion: @escaping (CalendarRangeEventsInfo) -> Void) {
        HabitRepository.fetchEventTasks(in: range) { tasks in
            guard let tasks = tasks else {
                completion(.empty(with: range))
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let events = tasks.toCalendarEvents(in: range)
                let dayColors = CalendarEventColorMapper.mapColorsByDay(events: events,
                                                                        range: range)
                let result = CalendarRangeEventsInfo(range: range, dayColors: dayColors)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    func addEventChangeDelegate(_ delegate: CalendarEventChangeDelegate) {
        changeObserver.addUpdaterDelegate(delegate)
    }
}

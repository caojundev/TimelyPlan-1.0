//
//  CalendarRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

protocol CalendarEventChangeDelegate: AnyObject {
    
    /// 当日历事件发生改变时触发
    func calendarEventsDidChange(in ranges: [DateInterval])
}

class CalendarRepository {
    
    // 可动态注册多个 Provider
    private var providers: [CalendarEventProvider] = []
    
    private var localProvider = CalendarLocalEventProvider()
    
    private var systemProvider = CalendarSystemEventProvider()
    
    private let updater = CalendarUpdater()
    
    init() {
        self.localProvider.delegate = self.updater
        self.systemProvider.delegate = self.updater
        self.providers = [self.localProvider, self.systemProvider]
    }
    
    func addUpdater(_ delegate: AnyObject) {
        updater.addDelegate(delegate)
    }
    
    func fetchEvents(in range: DateInterval, completion: @escaping([CalendarEvent]) -> Void) {
        var results = [CalendarEvent]()
        let group = DispatchGroup()
        for provider in providers {
            group.enter()
            provider.fetchEvents(in: range) { events in
                if let events = events, events.count > 0 {
                    results.append(contentsOf: events)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
    
    func updateEvent(_ event: CalendarEvent, with dateRange: DateInterval) {
        switch event.source {
        case .local:
            updateLocalEvent(event, with: dateRange)
        case .system:
            break
        }
    }
    
    private func updateLocalEvent(_ event: CalendarEvent, with dateRange: DateInterval) {
        if let task = event.sourceItem as? TodoTask {
            let schedule = TaskSchedule(dateInfo: dateRange.dateInfo,
                                        reminder: task.schedule?.reminder,
                                        repeatRule: task.schedule?.repeatRule)
            todo.updateTask(task, schedule: schedule)
        }
    }
}

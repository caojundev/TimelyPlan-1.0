//
//  CalendarRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

class CalendarRepository {
    
    // 可动态注册多个 Provider
    private var providers: [CalendarEventProvider] = []
    
    init() {
        let localProvider = CalendarLocalEventProvider()
        self.providers = [localProvider]
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
}

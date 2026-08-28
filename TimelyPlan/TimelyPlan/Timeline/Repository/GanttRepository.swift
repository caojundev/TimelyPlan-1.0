//
//  GanttRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

class GanttRepository {
    
    // 可动态注册多个 Provider
    private var providers: [GanttEventProvider] = []
    private var todoProvider = GanttTodoEventProvider()
    private let changeObserver = GanttEventChangeObserver()
    
    init() {
        self.providers = [self.todoProvider]
    }
    
    func addUpdaterDelegate(_ delegate: GanttEventChangeDelegate) {
        changeObserver.addUpdaterDelegate(delegate)
    }
    
    func removeUpdaterDelegate(_ delegate: GanttEventChangeDelegate) {
        changeObserver.removeUpdaterDelegate(delegate)
    }
    
    func fetchEvents(in range: DateInterval, completion: @escaping([GanttEvent]) -> Void) {
        var results = [GanttEvent]()
        let group = DispatchGroup()
        for provider in providers {
            group.enter()
            provider.fetchGanttEvents(in: range) { events in
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

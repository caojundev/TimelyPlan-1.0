//
//  MyDayRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

class MyDayRepository {
    
    // 可动态注册多个 Provider
    private var providers: [MyDayEventProvider] = []
    private var calendarProvider = MyDayCalendarEventProvider()
    private var todoProvider = MyDayTodoEventProvider()
    private var habitProvider = MyDayHabitEventProvider()
    private var focusProvider = MyDayFocusEventProvider()

    private let changeObserver = MyDayEventChangeObserver()
    
    init() {
        self.providers = [self.calendarProvider,
                          self.todoProvider,
                          self.habitProvider,
                          self.focusProvider]
    }
    
    func addUpdaterDelegate(_ delegate: MyDayEventChangeDelegate) {
        changeObserver.addUpdaterDelegate(delegate)
    }
    
    func removeUpdaterDelegate(_ delegate: MyDayEventChangeDelegate) {
        changeObserver.removeUpdaterDelegate(delegate)
    }
    
    func fetchEvents(in range: DateInterval, completion: @escaping([MyDayEvent]) -> Void) {
        var results = [MyDayEvent]()
        let group = DispatchGroup()
        for provider in providers {
            group.enter()
            provider.fetchMyDayEvents(in: range) { events in
                if let events = events, events.count > 0 {
                    results.append(contentsOf: events)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(results.orderedEvents)
        }
    }
}

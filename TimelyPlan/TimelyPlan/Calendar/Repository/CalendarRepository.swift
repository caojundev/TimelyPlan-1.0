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
    
    private var todoProvider = CalendarTodoEventProvider()
    private var habitProvider = CalendarHabitEventProvider()
    private var goalProvider = CalendarGoalEventProvider()
    private var countdownProvider = CalendarCountdownEventProvider()
    private var focusProvider = CalendarFocusEventProvider()
    private var systemProvider = CalendarSystemEventProvider()
    
    private let changeObserver = CalendarEventChangeObserver()
    
    init() {
        self.providers = [self.todoProvider,
                          self.habitProvider,
                          self.goalProvider,
                          self.countdownProvider,
                          self.focusProvider,
                          self.systemProvider]
    }
    
    func addUpdaterDelegate(_ delegate: CalendarEventChangeDelegate) {
        changeObserver.addUpdaterDelegate(delegate)
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
            completion(results.orderedEvents)
        }
    }
    
    func updateTodoEvent(_ event: CalendarEvent, with dateRange: DateInterval) {
        if let task = event.sourceItem as? TodoTask {
            let schedule = TaskSchedule(dateInfo: dateRange.dateInfo,
                                        reminder: task.schedule?.reminder,
                                        repeatRule: task.schedule?.repeatRule)
            TodoRepository.updateTask(task, schedule: schedule)
        }
    }
    
    func updateHabitEvent(_ event: CalendarEvent, with dateRange: DateInterval) {
        if let task = event.sourceItem as? HabitTask {
            var editingTask = task.editingTask
            editingTask.timeOption = .currentPeriod(from: dateRange.start)
            editingTask.startTime = Int64(dateRange.start.offset())
            editingTask.duration = Int64(dateRange.duration)
            HabitRepository.updateTask(task, with: editingTask)
        }
    }
    
    func updateGoalEvent(_ event: CalendarEvent, with dateRange: DateInterval) {
        if let task = event.sourceItem as? GoalTask {
            var editingTask = task.editingTask
            if event.isAllDay {
                editingTask.startTime = -1
            } else {
                editingTask.startTime = Int64(dateRange.start.offset())
                editingTask.duration = Int64(dateRange.duration)
            }
            
            GoalRepository.updateGoalTask(task, with: editingTask)
        }
    }
}

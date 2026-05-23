//
//  CalendarLocalEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

class CalendarLocalEventProvider: CalendarEventProvider {
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        todo.fetchScheduledTasks(in: range, showCompleted: true) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }

            let events = self.events(for: tasks)
            completion(events)
        }
    }
    
    func events(for tasks: [TodoTask]) -> [CalendarEvent] {
        var results = [CalendarEvent]()
        for task in tasks {
            if let event = event(with: task) {
                results.append(event)
            }
        }
        
        return results
    }
    
    func event(with task: TodoTask) -> CalendarEvent? {
        guard let dateInfo = task.schedule?.dateInfo else {
            return nil
        }
        
        let color = task.priority.color
        var isAllDay = dateInfo.isAllDay
        if !isAllDay && dateInfo.style == .multiDay {
            /// 跨天任务，显示为全天事项
            isAllDay = true
        }
        
        let event = CalendarEvent(identifier: task.identifier,
                                  source: .local,
                                  name: task.name,
                                  color: color,
                                  startDate: dateInfo.startDate,
                                  endDate: dateInfo.endDate,
                                  isAllDay: isAllDay,
                                  sourceItem: task)
        return event
    }
}

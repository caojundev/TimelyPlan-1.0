//
//  CalendarTodoEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

class CalendarTodoEventProvider: CalendarEventProvider {

    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        let showCompleted = CalendarSetting.shared.showCompletedTask
        TodoRepository.fetchCalendarEventTasks(in: range, showCompleted: showCompleted) { tasks in
            completion(tasks?.toCalendarEvents())
        }
    }
}

//
//  MyDayEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

protocol MyDayEventProvider {
    
    /// 获取特定日期范围的事项
    func fetchMyDayEvents(in range: DateInterval, completion: @escaping([MyDayEvent]?) -> Void)
}

class MyDayTodoEventProvider: MyDayEventProvider {
    
    func fetchMyDayEvents(in range: DateInterval, completion: @escaping ([MyDayEvent]?) -> Void) {
        guard MyDaySetting.shared.showTodo else {
            completion(nil)
            return
        }
        
        TodoRepository.fetchMyDayEventTasks(in: range, showCompleted: true) { tasks in
            completion(tasks?.toMyDayEvents())
        }
    }
}

class MyDayHabitEventProvider: MyDayEventProvider {
    
    func fetchMyDayEvents(in range: DateInterval, completion: @escaping ([MyDayEvent]?) -> Void) {
        guard MyDaySetting.shared.showHabit else {
            completion(nil)
            return
        }
        
        HabitRepository.fetchMyDayEventTasks(in: range) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }
            
            let events = tasks.toMyDayEvents(in: range)
            completion(events)
        }
    }
}

class MyDayFocusEventProvider: MyDayEventProvider {
    
    func fetchMyDayEvents(in range: DateInterval, completion: @escaping ([MyDayEvent]?) -> Void) {
        guard MyDaySetting.shared.showFocus else {
            completion(nil)
            return
        }
        
        FocusRepository.fetchMyDayEventTimers(in: range) { timers in
            guard let timers = timers else {
                completion(nil)
                return
            }

            let events = timers.toMyDayEvents(in: range)
            completion(events)
        }
    }
}


class MyDayCalendarEventProvider: MyDayEventProvider {
    
    func fetchMyDayEvents(in range: DateInterval, completion: @escaping ([MyDayEvent]?) -> Void) {
        guard MyDaySetting.shared.showCalendarEvent else {
            completion(nil)
            return
        }
        
        CalendarSystemManager.shared.fetchVisbleCalendarEvents(from: range.start,
                                                               to: range.end) { results in
            completion(results.toMyDayEvents())
        }
    }
}

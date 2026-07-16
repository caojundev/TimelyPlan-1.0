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
        TodoRepository.fetchMyDayEventTasks(in: range, showCompleted: true) { tasks in
            completion(tasks?.toMyDayEvents())
        }
    }
}

class MyDayHabitEventProvider: MyDayEventProvider {
    
    func fetchMyDayEvents(in range: DateInterval, completion: @escaping ([MyDayEvent]?) -> Void) {
        HabitRepository.fetchMyDayEventTasks(in: range) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let events = tasks.toMyDayEvents(in: range)
                DispatchQueue.main.async {
                    completion(events)
                }
            }
        }
    }
}

class MyDayFocusEventProvider: MyDayEventProvider {
    
    func fetchMyDayEvents(in range: DateInterval, completion: @escaping ([MyDayEvent]?) -> Void) {
        FocusRepository.fetchMyDayEventTimers(in: range) { timers in
            guard let timers = timers else {
                completion(nil)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let events = timers.toMyDayEvents(in: range)
                DispatchQueue.main.async {
                    completion(events)
                }
            }
        }
    }
}

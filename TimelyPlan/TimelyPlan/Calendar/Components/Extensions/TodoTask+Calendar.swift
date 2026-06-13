//
//  TodoTask+Calendar.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation

extension TodoTask {
    
    func toCalendarEvent() -> CalendarEvent? {
        guard let dateInfo = schedule?.dateInfo else {
            return nil
        }
        
        let color = priority.color
        var isAllDay = dateInfo.isAllDay
        if !isAllDay && dateInfo.style == .multiDay {
            /// 跨天任务，显示为全天事项
            isAllDay = true
        }
        
        let event = CalendarEvent(identifier: identifier,
                                  source: .local,
                                  name: name,
                                  color: color,
                                  startDate: dateInfo.startDate,
                                  endDate: dateInfo.endDate,
                                  isAllDay: isAllDay,
                                  sourceItem: self)
        return event
    }
}

// MARK: - Array 扩展
extension Array where Element == TodoTask {
    
    func toCalendarEvents() -> [CalendarEvent] {
        var results = [CalendarEvent]()
        for task in self {
            if let event = task.toCalendarEvent() {
                results.append(event)
            }
        }
        
        return results
    }
}

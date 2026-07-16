//
//  TodoTask+MyDayEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

extension TodoTask {
    
    func toMyDayEvent() -> MyDayEvent? {
        guard isAddedToMyDay, let dateInfo = schedule?.dateInfo else {
            return nil
        }
        
        let color = priority.color
        var isAllDay = dateInfo.isAllDay
        if !isAllDay && dateInfo.style == .multiDay {
            /// 跨天任务，显示为全天事项
            isAllDay = true
        }
        
        let event = MyDayEvent(identifier: identifier,
                               source: .todo,
                               name: displayName,
                               color: color,
                               startDate: dateInfo.startDate,
                               endDate: dateInfo.endDate,
                               isAllDay: isAllDay,
                               isCompleted: isCompleted,
                               sourceItem: self)
        return event
    }
}

// MARK: - Array 扩展
extension Array where Element == TodoTask {
    
    func toMyDayEvents() -> [MyDayEvent] {
        return compactMap { $0.toMyDayEvent() }
    }
}

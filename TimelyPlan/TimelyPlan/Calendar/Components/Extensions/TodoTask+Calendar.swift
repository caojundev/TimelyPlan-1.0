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
        
        var nameStrings = [String]()
        nameStrings.append(self.name ?? resGetString("Untitled"))
        if let progress = progress {
            let completionFraction = Float(progress.completionFraction)
            let percentageString = completionFraction.percentageString(decimalPlaces: 0)
            nameStrings.append(percentageString)
        }
        
        let name = nameStrings.joined(separator: "•")
        let event = CalendarEvent(identifier: identifier,
                                  source: .todo,
                                  name: name,
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
    
    func toCalendarEvents() -> [CalendarEvent] {
        return compactMap { $0.toCalendarEvent() }
    }
}

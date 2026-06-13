//
//  EKEvent+Extension.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation
import EventKit

// MARK: - EKEvent 扩展
extension EKEvent {
    
    var spanMultipleDays: Bool {
        return Date.days(fromDate: startDate, toDate: endDate) != 0
    }
    
    func toCalendarEvent() ->  CalendarEvent? {
        guard let identifier = self.eventIdentifier else {
            return nil
        }
        
        let color: UIColor
        if let cgColor = self.calendar.cgColor {
            color = UIColor(cgColor: cgColor)
        } else {
            color = .systemBlue
        }
        
        var isAllDay = self.isAllDay
        if !isAllDay {
            /// 跨天任务，显示为全天事项
            isAllDay = spanMultipleDays
        }
        
        return CalendarEvent(
            identifier: identifier,
            source: .system,
            name: self.title,
            color: color,
            startDate: self.startDate,
            endDate: self.endDate,
            isAllDay: isAllDay,
            sourceItem: self
        )
    }
}

// MARK: - Array 扩展
extension Array where Element == EKEvent {
    
    func toCalendarEvents() -> [CalendarEvent] {
        var results = [CalendarEvent]()
        for ekEvent in self {
            if let event = ekEvent.toCalendarEvent() {
                results.append(event)
            }
        }
        
        return results
    }
}

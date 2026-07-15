//
//  HabitTask+Calendar.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/30.
//

import Foundation

extension HabitTask {

    func calendarEvents(in range: DateInterval) -> [CalendarEvent]? {
        guard let startDate = dateRange.startDate else {
            return nil
        }
        
        var events = [CalendarEvent]()
        var planDate = timePlan.nextPlanDate(from: range.start,
                                             startDate: startDate,
                                             endDate: dateRange.endDate)
        while let date = planDate, date <= range.end {
            let event = event(on: date)
            events.append(event)
            
            if let nextReferenceDate = date.dateByAddingDays(1) {
                planDate = timePlan.nextPlanDate(from: nextReferenceDate,
                                                 startDate: startDate,
                                                 endDate: dateRange.endDate)
            } else {
                planDate = nil
            }
        }
        
        return events
    }
    
    func event(on planDate: Date) -> CalendarEvent {
        let isAllDay: Bool
        let interval: DateInterval
        if timeOption != .anytime {
            isAllDay = false
            let start = planDate.dateWithTimeOffset(Duration(validatedStartTime))
            var end = start.dateByAddingSeconds(Duration(validatedDuration)) ?? start
            if !end.isInSameDayAs(start) {
                end = start.endOfDay()
            }
            
            interval = DateInterval(start: start, end: end)
        } else {
            isAllDay = true
            interval = .rangeOfDay(planDate)
        }
        
        let event = CalendarEvent(identifier: identifier,
                                  source: .habit,
                                  name: displayTitle,
                                  color: color,
                                  startDate: interval.start,
                                  endDate: interval.end,
                                  isAllDay: isAllDay,
                                  isCompleted: false,
                                  sourceItem: self)
        return event
    }
}

// MARK: - Array 扩展
extension Array where Element == HabitTask {
    
    func toCalendarEvents(in range: DateInterval) -> [CalendarEvent] {
        var results = [CalendarEvent]()
        for task in self {
            if let events = task.calendarEvents(in: range) {
                results.append(contentsOf: events)
            }
        }
    
        return results
    }
}

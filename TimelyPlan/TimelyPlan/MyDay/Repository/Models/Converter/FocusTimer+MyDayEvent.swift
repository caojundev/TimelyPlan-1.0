//
//  FocusTimer+MyDayEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

extension FocusTimer {

    func myDayEvents(in range: DateInterval) -> [MyDayEvent]? {
        guard isAddedToMyDay, let startDate = startDate else {
            return nil
        }
        
        var events = [MyDayEvent]()
        var planDate = timePlan.nextPlanDate(from: range.start,
                                             startDate: startDate,
                                             endDate: endDate)
        while let date = planDate, date <= range.end {
            let event = myDayEvent(on: date)
            events.append(event)
            
            if let nextReferenceDate = date.dateByAddingDays(1) {
                planDate = timePlan.nextPlanDate(from: nextReferenceDate,
                                                 startDate: startDate,
                                                 endDate: endDate)
            } else {
                planDate = nil
            }
        }
        
        return events
    }
    
    private func myDayEvent(on planDate: Date) -> MyDayEvent {
        let isAllDay: Bool
        let interval: DateInterval
        if startTime > 0 {
            isAllDay = false
            let start = planDate.dateWithTimeOffset(Duration(startTime))
            var duration = config.duration
            let minDuration = TimeInterval(SECONDS_PER_MINUTE)
            if duration <= minDuration {
               duration = minDuration
            }
            
            interval = DateInterval(start: start, duration: duration)
        } else {
            isAllDay = true
            interval = .rangeOfDay(planDate)
        }
        
        let event = MyDayEvent(identifier: identifier,
                                  source: .focus,
                                  name: displayName,
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
extension Array where Element == FocusTimer {
    
    func toMyDayEvents(in range: DateInterval) -> [MyDayEvent] {
        var results = [MyDayEvent]()
        for task in self {
            if let events = task.myDayEvents(in: range) {
                results.append(contentsOf: events)
            }
        }
    
        return results
    }
}

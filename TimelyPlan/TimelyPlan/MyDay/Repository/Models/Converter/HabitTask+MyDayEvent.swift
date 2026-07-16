//
//  HabitTask+MyDayEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

extension HabitTask {

    func myDayEvents(in range: DateInterval) -> [MyDayEvent]? {
        guard isAddedToMyDay, let startDate = dateRange.startDate else {
            return nil
        }
        
        var events = [MyDayEvent]()
        var planDate = timePlan.nextPlanDate(from: range.start,
                                             startDate: startDate,
                                             endDate: dateRange.endDate)
        while let date = planDate, date <= range.end {
            let event = myDayEvent(on: date)
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
    
    private func myDayEvent(on planDate: Date) -> MyDayEvent {
        let isAllDay: Bool
        let interval: DateInterval
        if timeOption != .anytime {
            isAllDay = false
            let start = planDate.dateWithTimeOffset(Duration(validatedStartTime))
            interval = DateInterval(start: start, duration: TimeInterval(validatedDuration))
        } else {
            isAllDay = true
            interval = .rangeOfDay(planDate)
        }
        
        let event = MyDayEvent(identifier: identifier,
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

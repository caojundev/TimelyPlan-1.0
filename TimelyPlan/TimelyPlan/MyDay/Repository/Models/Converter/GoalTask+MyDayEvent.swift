//
//  GoalTask+MyDayEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/12.
//

import Foundation

extension GoalTask {

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
        if startTime >= 0 {
            isAllDay = false
            let start = planDate.dateWithTimeOffset(Duration(startTime))
            var end = start.dateByAddingSeconds(Duration(validatedDuration)) ?? start
            if !end.isInSameDayAs(start) {
                /// 跨天时截断到当天结束
                end = start.endOfDay()
            }
            
            interval = DateInterval(start: start, end: end)
        } else {
            isAllDay = true
            interval = .rangeOfDay(planDate)
        }
        
        let event = MyDayEvent(identifier: identifier,
                               source: .goal,
                               name: displayName,
                               color: color ?? Self.defaultColor,
                               startDate: interval.start,
                               endDate: interval.end,
                               isAllDay: isAllDay,
                               isCompleted: isCompleted,
                               sourceItem: self)
        return event
    }
    
    /// 合法持续时长（至少一分钟）
    private var validatedDuration: Int64 {
        if duration < Int64(SECONDS_PER_MINUTE) {
            return Int64(SECONDS_PER_MINUTE)
        }
        
        return duration
    }
}

// MARK: - Array 扩展
extension Array where Element == GoalTask {
    
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

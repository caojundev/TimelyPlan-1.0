//
//  CalendarEventsProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/14.
//

import Foundation

class CalendarEventsProvider {
    
    /// 当前日期范围事项改变
    var eventsDidChange: (() -> Void)?

    private(set) var dateRange: DateRange?

    /// 所有事件
    private(set) var events: [CalendarEvent]?

    init() {
        
    }
    
    func contains(date: Date) -> Bool {
        guard let dateRange = dateRange else {
            return false
        }

        return dateRange.contains(date: date)
    }
    
    func loadEvents() {
        guard let dateRange = dateRange else {
            return
        }

        loadEvents(in: dateRange)
    }
    
    func loadEvents(in dateRange: DateRange) {
        self.dateRange = dateRange
        fetchEvents(in: dateRange) { events in
            guard self.dateRange == dateRange else {
                return
            }
            
            self.events = events
            self.eventsDidChange?()
        }
    }
    
    private func fetchEvents(in dateRange: DateRange,
                             completion:@escaping([CalendarEvent]?) -> Void) {
        guard let startDate = dateRange.startDate, let endDate = dateRange.endDate else {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let now = startDate
            let events = [
                CalendarEvent(name: "产品评审02",
                              color: CalendarEventColor.random,
                              startDate: calendar.date(bySettingHour: 9, minute: 10, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 10, minute: 40, second: 0, of: now)!),
                CalendarEvent(name: "晨会01",
                              color: CalendarEventColor.random,
                              startDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now)!),
                
                CalendarEvent(name: "阅读",
                              color: CalendarEventColor.random,
                              startDate: calendar.date(bySettingHour: 10, minute: 05, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 10, minute: 50, second: 0, of: now)!),
                
                CalendarEvent(name: "开发 Coding 03",
                              color: CalendarEventColor.random,
                              startDate: calendar.date(bySettingHour: 9, minute: 40, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!)
                
            ]
            
            DispatchQueue.main.async {
                completion(events)
            }
        }
    }
}

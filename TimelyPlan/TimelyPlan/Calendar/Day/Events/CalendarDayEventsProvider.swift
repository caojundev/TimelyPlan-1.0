//
//  CalendarDayEventsProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/9.
//

import Foundation

class CalendarDayEventsProvider {
    
    var eventsDidChange: (() -> Void)?
    
    private(set) var events: [CalendarEvent]?
    
    private(set) var date: Date = .now
    
    init() {
        
    }
    
    func loadEvents() {
        self.loadEvents(for: self.date)
    }
    
    func loadEvents(for date: Date) {
        self.date = date
        fetchEvents(on: date) { events in
            guard self.date.isInSameDayAs(date) else {
                print("非相同日期: 获取的是\(date.yearMonthDayString)，当前日期\(self.date.yearMonthDayString)")
                return
            }
            
            self.events = events
            self.eventsDidChange?()
        }
    }
    
    private func fetchEvents(on date: Date, completion:@escaping([CalendarEvent]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let now = self.date
            let events = [
                CalendarEvent(name: "晨会",
                              color: CalendarEventColor.random,
                              startDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now)!),
                CalendarEvent(name: "产品评审",
                              color: CalendarEventColor.random,
                              startDate: calendar.date(bySettingHour: 9, minute: 10, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 10, minute: 40, second: 0, of: now)!),
                
                CalendarEvent(name: "开发 Coding",
                              color: CalendarEventColor.random,
                              startDate: calendar.date(bySettingHour: 10, minute: 00, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!),
                CalendarEvent(name: "阅读",
                              color: CalendarEventColor.random,
                              startDate: calendar.date(bySettingHour: 10, minute: 05, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 10, minute: 50, second: 0, of: now)!),
                
//                CalendarEvent(name: "阅读",
//                              color: CalendarEventColor.random,
//                              startDate: calendar.date(bySettingHour: 13, minute: 00, second: 0, of: now)!,
//                              endDate: calendar.date(bySettingHour: 15, minute: 40, second: 0, of: now)!),
            ]
            
            DispatchQueue.main.async {
                completion(events)
            }
        }
    }
    
}

//
//  CalendarWeekEventsProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/11.
//

import Foundation

class CalendarWeekEventsProvider {
    
    /// 周开始日期
    var weekStartDate: Date?
    
    var eventsDidChange: (() -> Void)?
    
    /// 全天事件
    private(set) var allDayEvents: [CalendarEvent]?
    
    /// 定时事件
    private(set) var timedEvents: [CalendarEvent]?
    
    /// 所有事件
    private var events: [CalendarEvent]?
    
    init() {
        
    }

    func loadEvents(with weekStartDate: Date) {
        self.weekStartDate = weekStartDate
        fetchEvents(on: weekStartDate) { events in
            guard self.weekStartDate == weekStartDate else {
                print("非相同日期: 获取的是\(weekStartDate.yearMonthDayString)，当前日期\(self.weekStartDate?.yearMonthDayString)")
                return
            }
            
            self.timedEvents = events
            self.allDayEvents = self.getTestAllDayEvents()
            self.eventsDidChange?()
        }
    }
    
    private func fetchEvents(on date: Date, completion:@escaping([CalendarEvent]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let now = date
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
                              startDate: calendar.date(bySettingHour: 9, minute: 40, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!),
                CalendarEvent(name: "阅读",
                              color: CalendarEventColor.random,
                              startDate: calendar.date(bySettingHour: 10, minute: 05, second: 0, of: now)!,
                              endDate: calendar.date(bySettingHour: 10, minute: 50, second: 0, of: now)!)
            ]
            
            DispatchQueue.main.async {
                completion(events)
            }
        }
    }
    
    private func getTestAllDayEvents() -> [CalendarEvent] {
        guard let weekStartDate = weekStartDate else {
            return  []
        }
        
        var events = [CalendarEvent]()
        var event = CalendarEvent(name: "事件名称1",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(2)!)
        events.append(event)

        event = CalendarEvent(name: "事件名称2",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(2)!,
                                  endDate: weekStartDate.dateByAddingDays(4)!)
        events.append(event)

        event = CalendarEvent(name: "事件名称3",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(3)!,
                                  endDate: weekStartDate.dateByAddingDays(3)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称4",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(4)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称5",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称6",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(4)!,
                                  endDate: weekStartDate.dateByAddingDays(5)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称7",
                              color: CalendarEventColor.random,
                              startDate: weekStartDate,
                              endDate: weekStartDate.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称8",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称9",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称10",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(2)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称11",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(2)!,
                                  endDate: weekStartDate.dateByAddingDays(2)!)
        events.append(event)
        
        return events
    }
}

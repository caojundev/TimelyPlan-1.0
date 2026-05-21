//
//  CalendarLocalEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

class CalendarLocalEventProvider: CalendarEventProvider {
    
    func fetchEvents(in range: DateInterval, completion: @escaping ([CalendarEvent]?) -> Void) {
        let calendar = Calendar.current
        let now = range.start
        let timeredEvents = [
            CalendarEvent(name: "A产品评审02",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 10, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 40, second: 0, of: now)!,
                         isAllDay: false),
            CalendarEvent(name: "B晨会01",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now)!,
                          isAllDay: false),
            
            CalendarEvent(name: "C阅读",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 10, minute: 05, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 50, second: 0, of: now)!,
                          isAllDay: false),
            
            CalendarEvent(name: "D开发 Coding 03",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 40, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!,
                          isAllDay: false)
            
        ]
  
        let date = range.start
        let allDayEvents = [
            CalendarEvent(name: "全天事项1",
                          color: CalendarEventColor.random,
                          startDate: date.dateByAddingDays(1)!,
                          endDate: date.dateByAddingDays(2)!,
                          isAllDay: true),

            CalendarEvent(name: "全天事项2",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(2)!,
                                  endDate: date.dateByAddingDays(4)!,
                          isAllDay: true),

            CalendarEvent(name: "全天事项3",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(3)!,
                                  endDate: date.dateByAddingDays(3)!,
                          isAllDay: true),
            
            CalendarEvent(name: "全天事项4",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(4)!,
                          isAllDay: true),
        
            CalendarEvent(name: "全天事项5",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(1)!,
                          isAllDay: true),
            
            CalendarEvent(name: "全天事项6",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(4)!,
                                  endDate: date.dateByAddingDays(5)!,
                          isAllDay: true),
        
            CalendarEvent(name: "全天事项7",
                              color: CalendarEventColor.random,
                              startDate: date,
                              endDate: date.dateByAddingDays(1)!,
                          isAllDay: true),
        
            CalendarEvent(name: "全天事项8",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(1)!,
                          isAllDay: true),
        
            CalendarEvent(name: "全天事项9",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(1)!,
                          isAllDay: true),
        
            CalendarEvent(name: "全天事项10",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(2)!,
                          isAllDay: true),
        
            CalendarEvent(name: "全天事项11",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(2)!,
                                  endDate: date.dateByAddingDays(2)!,
                          isAllDay: true),
            
            CalendarEvent(name: "全天事项12",
                              color: CalendarEventColor.random,
                              startDate: date,
                              endDate: date.dateByAddingDays(1)!,
                          isAllDay: true),
        
            CalendarEvent(name: "全天事项13",
                              color: CalendarEventColor.random,
                              startDate: date,
                              endDate: date.dateByAddingDays(1)!,
                          isAllDay: true)
        ]
        
        completion(timeredEvents + allDayEvents)
    }
    
}

//
//  CalendarYearEventsFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/5.
//

import Foundation

class CalendarYearEventsFetcher: CalendarYearEventsProvider {
    private let repository = CalendarRepository()
    private let calculationQueue = DispatchQueue(label: "com.calendar.eventCalculation",
                                                  qos: .userInitiated,
                                                  attributes: .concurrent)
    func fetchEventsForMonth(year: Int, month: Int, completion: @escaping (CalendarMonthEventsInfo) -> Void) {
        guard let interval = Calendar.current.monthInterval(year: year, month: month) else {
            let info = CalendarMonthEventsInfo(year: year, month: month, dayEvents: [])
            completion(info)
            return
        }
        
        repository.fetchEvents(in: interval) { [weak self] events in
            guard let self = self else { return }
            self.calculationQueue.async {
                let dayEvents = self.calculateDayEvents(
                    events: events,
                    year: year,
                    month: month,
                    monthInterval: interval
                )
                
                let result = CalendarMonthEventsInfo(year: year, month: month, dayEvents: dayEvents)
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    /// 优化版本：使用 Set 去重，减少数组查找
    private func calculateDayEvents(
        events: [CalendarEvent],
        year: Int,
        month: Int,
        monthInterval: DateInterval
    ) -> [CalendarDayEventInfo] {
        let calendar = Calendar.current
        
        guard let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: startDate) else {
            return []
        }
        
        let daysInMonth = range.count
        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end
        
        // 使用有序字典保持颜色插入顺序
        var dayColorsMap: [Int: OrderedSet<UIColor>] = [:]
        
        // 预分配内存，减少动态扩容
        for day in 1...daysInMonth {
            dayColorsMap[day] = OrderedSet<UIColor>()
        }
        
        for event in events {
            let eventStart = max(event.startDate, monthStart)
            let eventEnd = min(event.endDate, monthEnd)
            
            guard eventStart <= eventEnd else { continue }
            
            // 计算开始和结束的天索引
            let startDay = calendar.component(.day, from: eventStart)
            let endDay = calendar.component(.day, from: eventEnd)
            
            // 直接遍历天数，避免创建 Date 数组
            for day in startDay...endDay {
                guard day >= 1 && day <= daysInMonth else { break }
                dayColorsMap[day]?.append(event.color)
            }
        }
        
        // 构建结果
        var dayEvents: [CalendarDayEventInfo] = []
        dayEvents.reserveCapacity(daysInMonth)
        
        for day in 1...daysInMonth {
            let colors = dayColorsMap[day]?.array ?? []
            dayEvents.append(CalendarDayEventInfo(day: day, indicatorColors: colors))
        }
        
        return dayEvents
    }
}

// MARK: - 有序集合（去重且保持插入顺序）
struct OrderedSet<T: Hashable> {
    private var elements: [T] = []
    private var set: Set<T> = []
    
    var array: [T] { return elements }
    
    mutating func append(_ element: T) {
        if !set.contains(element) {
            elements.append(element)
            set.insert(element)
        }
    }
    
    mutating func append(contentsOf newElements: [T]) {
        for element in newElements {
            append(element)
        }
    }
}

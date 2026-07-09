//
//  CalendarRangeEventsInfoFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/9.
//

import Foundation

class CalendarRangeEventsInfoFetcher: CalendarRangeEventsProvider {
    
    private let repository = CalendarRepository()
    private let calculationQueue = DispatchQueue(label: "com.calendar.rangeEvents",
                                                  qos: .userInitiated,
                                                  attributes: .concurrent)
    
    func fetchRangeEventsInfo(in range: DateInterval, completion: @escaping (CalendarRangeEventsInfo) -> Void) {
        repository.fetchEvents(in: range) { [weak self] events in
            guard let self = self else { return }
            self.calculationQueue.async {
                let dayColors = self.calculateDayColors(events: events, range: range)
                let result = CalendarRangeEventsInfo(range: range, dayColors: dayColors)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    private func calculateDayColors(
        events: [CalendarEvent],
        range: DateInterval
    ) -> [DateComponents: [UIColor]] {
        let calendar = Calendar.current
        // 使用有序字典保持颜色插入顺序
        var dayColorsMap: [DateComponents: OrderedSet<UIColor>] = [:]
        for event in events {
            let eventStart = max(event.startDate, range.start)
            let eventEnd = min(event.endDate, range.end)
            guard eventStart <= eventEnd else { continue }
        
            let eventRange = DateInterval(start: eventStart, end: eventEnd)
            eventRange.enumerateDays { date in
                let key = calendar.dateComponents([.year, .month, .day], from: date)
                dayColorsMap[key, default: OrderedSet<UIColor>()].append(event.color)
                return true
            }
        }
    
        return dayColorsMap.mapValues { $0.array }
    }
}

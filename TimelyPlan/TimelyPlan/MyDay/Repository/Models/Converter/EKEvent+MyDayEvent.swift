//
//  EKEvent+MyDayEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/10.
//

import Foundation
import EventKit

extension EKEvent {
    
    func toMyDayEvent() -> MyDayEvent? {
        guard let identifier = eventIdentifier else {
            return nil
        }
        
        let color: UIColor
        if let cgColor = calendar.cgColor {
            color = UIColor(cgColor: cgColor)
        } else {
            color = .systemBlue
        }
        
        var isAllDay = isAllDay
        if !isAllDay {
            /// 跨天任务，显示为全天事项
            isAllDay = spanMultipleDays
        }
        
        return MyDayEvent(identifier: identifier,
                          source: .calendar,
                          name: title,
                          color: color,
                          startDate: startDate,
                          endDate: endDate,
                          isAllDay: isAllDay,
                          isCompleted: false, sourceItem: self)
    }
}

// MARK: - Array 扩展
extension Array where Element == EKEvent {
    
    func toMyDayEvents() -> [MyDayEvent] {
        return compactMap { $0.toMyDayEvent() }
    }
}

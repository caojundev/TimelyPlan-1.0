//
//  Date+DateRange.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/21.
//

import Foundation

extension Date {
    
    /// 即将到来日期范围（后天～第7天）
    static func upcomingDateRange(of date: Date = .now) -> DateRange {
        let startDate = date.dateByAddingDays(2)?.startOfDay()
        let endDate = date.dateByAddingDays(6)?.endOfDay()
        return DateRange(startDate: startDate, endDate: endDate)
    }
    
    func upcomingDateRange() -> DateRange {
        return Date.upcomingDateRange(of: self)
    }
    
}

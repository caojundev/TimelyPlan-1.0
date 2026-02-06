//
//  Date+Year.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/10.
//

import Foundation

extension Date {
    
    func startOfYear() -> Date {
        let date = firstDayOfYear()
        return date.startOfDay()
    }

    func endOfYear() -> Date {
        let date = lastDayOfYear()
        return date.endOfDay()
    }
    
    /// 日期所在年的第一天
    func firstDayOfYear() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components)!
    }
    
    /// 日期所在年的最后一天
    func lastDayOfYear() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: self)
        components.month = 12
        components.day = 31
        return calendar.date(from: components)!
    }
    
}

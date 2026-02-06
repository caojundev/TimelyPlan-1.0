//
//  Date+Hour.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/10.
//

import Foundation

extension Date {
    
    /// 获取日期所在小时的开始时间（即整点时间）
    func startOfHour() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        return calendar.date(from: components)!
    }

    /// 获取日期所在小时的结束时间（即整点时间的下一小时减去一秒）
    func endOfHour() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        components.hour = (components.hour ?? 0) + 1
        components.second = -1
        return calendar.date(from: components)!
    }
}

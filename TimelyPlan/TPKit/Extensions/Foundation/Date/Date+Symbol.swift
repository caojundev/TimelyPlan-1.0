//
//  Date+Symbol.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/20.
//

import Foundation

// MARK: - 符号
extension Date {
    
    /// 获取月份中对应第几天字符
    var dayOfTheMonthOrdinalSymbol: String {
        return dayOfTheMonthOrdinalSymbol(prefix: nil, suffix: nil)
    }
    
    func dayOfTheMonthOrdinalSymbol(prefix: String?, suffix: String?) -> String {
        let format = day.ordinalSuffixFormat(prefix: prefix, suffix: suffix)
        let symbol = String(format: resGetString(format), day)
        return symbol
    }
}

/// 预设日期
extension Date {
    
    /// 获取当前日期
    static var now: Date {
        return Date()
    }
    
    /// 获取明天当下对应的日期
    static var tomorrow: Date {
        return Date().dateByAddingDays(1)!
    }
    
    // 下周一
    static var nextMonday: Date {
        return nextDateOfWeekday(2)
    }
    
    /// 下月1号日期
    static var firstDayOfNextMonth: Date {
        let lastDayDate = Date().lastDayOfMonth()
        return lastDayDate.dateByAddingDays(1)!
    }
    
    /// 返回下一个周几的日期
    static func nextDateOfWeekday(_ weekday: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        var count = (7 + weekday - calendar.component(.weekday, from: today)) % 7
        if count == 0 {
            count = 7
        }
        
        return calendar.date(byAdding: .day, value: count, to: today) ?? today
    }
}

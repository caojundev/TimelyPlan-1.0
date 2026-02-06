//
//  Date.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/10.
//

import Foundation

// MARK: - 农历
extension DateFormatter {
    
    /// 农历格式化
    static func lunarFormatter(dateFormat: String) -> DateFormatter {
        let calendar = Calendar.init(identifier: .chinese)
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateStyle = .medium
        formatter.dateFormat = dateFormat
        return formatter
    }
}

extension Date {
    /// 农历月字符串数组
    static var lunarMonthStrings = ["正月", "二月", "三月", "四月", "五月", "六月",
                                    "七月", "八月", "九月", "十月", "冬月", "腊月"]
    
    var lunarComponents: DateComponents {
        // 使用 .chinese 创建对应的农历的 Calendar
        let calendar = Calendar.init(identifier: .chinese)
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return components
    }
    
    /// 农历年
    var lunarYear: Int {
        return lunarComponents.year!
    }
    
    /// 农历月
    var lunarMonth: Int {
        return lunarComponents.month!
    }
    
    /// 农历月字符串
    var lunarMonthString: String {
        let formatter = DateFormatter.lunarFormatter(dateFormat: "MMM")
        return formatter.string(from: self)
    }
    
    /// 农历天
    var lunarDay: Int {
        return lunarComponents.day!
    }
    
    /// 农历天字符串
    var lunarDayString: String {
        let formatter = DateFormatter.lunarFormatter(dateFormat: "d")
        return formatter.string(from: self)
    }
    
    /// 农历月日字符串
    var lunarMonthDayString: String {
        let formatter = DateFormatter.lunarFormatter(dateFormat: "MMMd")
        return formatter.string(from: self)
    }
    
    /// 农历日历天显示字符串
    var lunarCalendarDayString: String {
        if lunarDay == 1 {
            let index = lunarMonth - 1
            return Date.lunarMonthStrings[index]
        }
        
        return lunarDayString
    }
    
    /// 判断日期是否为农历月的初一
    var isLunarFisrtDay: Bool {
        return lunarDay == 1
    }
    
    /// 根据是否为除夕（农历的每月天数是不确定的，并且每年可能还会有闰月的情况，需要单独判断）
    var isLunarNewYearEve: Bool {
        let nextDay = self.dateByAddingDays(1)!
        if nextDay.lunarMonth == 1 && nextDay.lunarDay == 1 {
            return true
        }
        
        return false
    }
}

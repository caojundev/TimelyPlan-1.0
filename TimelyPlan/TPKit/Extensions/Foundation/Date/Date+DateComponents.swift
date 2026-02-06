//
//  Date+DateComponents.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/11.
//

import Foundation

extension Date {

    /// 计算当前日期的年月日期
    var yearDate: Date? {
        let components = self.yearComponents
        return Date.dateFromComponents(components)
    }
    
    var yearMonthDate: Date? {
        let components = self.yearMonthComponents
        return Date.dateFromComponents(components)
    }
    
    var yearMonthDayDate: Date? {
        let components = self.yearMonthDayComponents
        return Date.dateFromComponents(components)
    }
    
    /// 计算当前日期的年组件
    var yearComponents: DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return components
    }
    
    /// 计算当前日期的年月组件
    var yearMonthComponents: DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return components
    }
    
    /// 计算当前日期的年月日组件
    var yearMonthDayComponents: DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return components
    }
    
    /// 获取日期组件对应的日期
    static func date(from components: DateComponents) -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: components)
    }
    
    /// 获取日期组件对应的日期
    static func dateFromComponents(_ components: DateComponents) -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: components)
    }
    
    /// 年月日时分秒、毫秒组件
    var components: DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
        return components
    }

}


extension DateComponents {
    
    /// 是否是今日的日期组件
    var isToday: Bool {
        let calendar = Calendar.current
        if let date = calendar.date(from: self) {
            return calendar.isDateInToday(date)
        }
        
        return false
    }
    
    /// 根据给定的月数，计算当前日期增加指定月份后的年月组件。
    ///
    /// - Parameter months: 要增加的月数，可以是负数以表示减少的月数。
    /// - Returns: 增加指定月份后的年月组件，如果日期计算失败，则返回 nil。
    func yearMonthCompontentsByAddingMonths(_ months: Int) -> DateComponents? {
        let calendar = Calendar.current
        guard let fromDate = calendar.date(from: self) else { return nil }
        guard let toDate = fromDate.dateByAddingMonths(months)  else { return nil }
        return toDate.yearMonthComponents
    }
    
    func yearMonthDayCompontentsByAddingWeeks(_ weeks: Int) -> DateComponents? {
        let calendar = Calendar.current
        guard let fromDate = calendar.date(from: self) else { return nil }
        guard let toDate = fromDate.dateByAddingWeeks(weeks)  else { return nil }
        return toDate.yearMonthDayComponents
    }
    
    /// 是否是同一个月份的日期组件
    func isInSameMonth(as other: DateComponents) -> Bool {
        return self.year == other.year && self.month == other.month
    }
}

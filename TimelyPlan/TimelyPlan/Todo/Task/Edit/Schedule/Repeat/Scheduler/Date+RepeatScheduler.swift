//
//  Date+RepeatScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/5.
//

import Foundation

extension Date {
    
    /// 获取特定日期所在月份的某个特定周几的日期
    /// - Parameters:
    ///   - dayOfWeek: 重复的周几
    ///   - inMonthOf: 特定日期
    /// - Returns: 对应的日期，如果没有则返回 nil
    static func dateForRepeatDayOfWeek(_ dayOfWeek: RepeatDayOfWeek, inMonthOf date: Date) -> Date? {
        let calendar = Calendar.current
        
        // 获取特定日期所在月份的年份和月份
        let components = calendar.dateComponents([.year, .month], from: date)
        
        // 设置目标日期的组件
        var targetComponents = DateComponents()
        targetComponents.year = components.year
        targetComponents.month = components.month
        targetComponents.weekday = dayOfWeek.dayOfTheWeek.rawValue
        targetComponents.weekdayOrdinal = dayOfWeek.weekNumber
        
        // 获取目标日期
        let targetDate = calendar.date(from: targetComponents)
        
        // 检查目标日期是否在指定月份内
        if let targetDate = targetDate, calendar.component(.month, from: targetDate) == components.month {
            return targetDate
        }
        
        return nil
    }
}

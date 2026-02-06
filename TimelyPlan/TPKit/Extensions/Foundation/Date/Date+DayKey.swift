//
//  Date+DayKey.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/6.
//

import Foundation

/// 习惯记录键值对应日期format
fileprivate let dayKeyFormat = "yyyyMMdd"

typealias DayStringKey = String
typealias DayIntegerKey = Int32

extension Date {
    
    /// 从习惯记录键获取日期
    static func dateFromDayStringKey(_ key: String) -> Date? {
        guard key.count == 8 else {
            return nil
        }
        
        return Date.date(withString: key, format: dayKeyFormat) as Date?
    }
    
    /// 从Int类型习惯记录键获取日期
    static func dateFromDayIntegerKey(_ key: Int32) -> Date? {
        let strKey = String(key)
        return dateFromDayStringKey(strKey)
    }
    
    /// 从日期获取对应的习惯记录键
    static func dayStringKey(for date: Date) -> String {
        return date.stringWithFormat(dayKeyFormat)
    }
    
    static func dayIntegerKey(for date: Date) -> Int32 {
        let str = dayStringKey(for: date)
        return Int32(str) ?? 0
    }
    
    // MARK: - 实例方法
    var dayStringKey: String {
        return Date.dayStringKey(for: self)
    }
    
    var dayIntegerKey: Int32 {
        return Date.dayIntegerKey(for: self)
    }
}

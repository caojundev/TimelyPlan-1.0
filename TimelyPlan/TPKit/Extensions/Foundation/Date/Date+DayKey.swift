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
        return DayKeyFormatter.shared.string(from: date)
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

// MARK: - 天键格式化器

/// 天键格式化器。
///
/// 天键在记录、缓存与查询条件中高频使用，而 `DateFormatter` 创建开销较大；
/// 这里缓存一份重复使用，时区或地区变化时重建，保证键值与当前环境一致。
private final class DayKeyFormatter: NSObject {
    
    static let shared = DayKeyFormatter()
    
    /// 天键格式化器
    private var formatter = DateFormatter()
    
    private let lock = NSLock()
    
    private override init() {
        super.init()
        rebuild()
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(environmentDidChange),
                           name: .NSSystemTimeZoneDidChange,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(environmentDidChange),
                           name: NSLocale.currentLocaleDidChangeNotification,
                           object: nil)
    }
    
    /// 日期格式化为天键
    func string(from date: Date) -> String {
        lock.lock()
        defer { lock.unlock() }
        
        return formatter.string(from: date)
    }
    
    /// 时区或地区变化后重建
    @objc private func environmentDidChange() {
        lock.lock()
        defer { lock.unlock() }
        
        rebuild()
    }
    
    private func rebuild() {
        let formatter = DateFormatter()
        formatter.dateFormat = dayKeyFormat
        formatter.locale = Locale.current
        self.formatter = formatter
    }
}

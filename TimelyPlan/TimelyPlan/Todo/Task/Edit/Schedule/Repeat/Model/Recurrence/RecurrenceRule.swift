//
//  RecurrenceRule.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/20.
//

import Foundation

/// 重复频率
enum RepeatFrequency: Int, Codable, Hashable, TPMenuRepresentable {
    case daily = 0 /// 每天
    case weekly    /// 每周
    case monthly   /// 每月
    case yearly    /// 每年
    
    /// 标题
    var title: String {
        switch self {
        case .daily:
            return resGetString("Daily")
        case .weekly:
            return resGetString("Weekly")
        case .monthly:
            return resGetString("Monthly")
        case .yearly:
            return resGetString("Yearly")
        }
    }
    
    /// 重复频率对应的单位
    var unit: String {
        return unit(for: 0)
    }
    
    func unit(for count: Int) -> String {
        let unit: String
        switch self {
        case .daily:
            unit = count > 1 ? "Days" : "Day"
        case .weekly:
            unit = count > 1 ? "Weeks" : "Week"
        case .monthly:
            unit = count > 1 ? "Months" : "Month"
        case .yearly:
            unit = count > 1 ? "Years" : "Year"
        }
        
        return unit
    }
    
    var localizedUnit: String {
        return localizedUnit(for: 0)
    }
    
    func localizedUnit(for count: Int) -> String {
        let unit = unit(for: count)
        return resGetString(unit)
    }
    
}

enum RecurrenceRuleType: Int, Codable, TPMenuRepresentable {
    case regularly // 定期
    case afterCompletion // 完成后
    case specificDates // 特定日期
    
    static func titles() -> [String] {
        return ["Regularly",
                "After Completion",
                "Specific Dates"]
    }
}

struct RecurrenceRule: Codable, Equatable, Hashable {
    
    /// 类型
    var type: RecurrenceRuleType? = .regularly
    
    /// 频率
    var frequency: RepeatFrequency? = .daily
    
    /// 重复间隔
    var interval: Int? = 1

    /// 与定期规则关联的周中的几天
    var daysOfTheWeek: [RepeatDayOfWeek]?
    
    /// 与定期规则关联的月份中的几天,（1～31，-1表示最后一天）
    var daysOfTheMonth: [Int]?
    
    /// 年中的月份数组（1 到 12）
    var monthsOfTheYear: [Int]?
    
    // 特定日期数组 (针对特定日期类型)
    var specificDates: [Date]?
    
    /// 重复月模式
    var monthlyMode: RepeatMonthlyMode {
        if let daysOfTheMonth = daysOfTheMonth, daysOfTheMonth.count > 0 {
            return .onDays
        }
        
        return .onWeek
    }
    
    init(type: RecurrenceRuleType = .regularly,
         frequency: RepeatFrequency = .daily,
         interval: Int = 1,
         daysOfTheWeek: [RepeatDayOfWeek]? = nil,
         daysOfTheMonth: [Int]? = nil,
         monthsOfTheYear: [Int]? = nil,
         specificDates: [Date]? = nil) {
        self.type = type
        self.frequency = frequency
        self.interval = interval
        self.daysOfTheWeek = daysOfTheWeek
        self.daysOfTheMonth = daysOfTheMonth
        self.monthsOfTheYear = monthsOfTheYear
        self.specificDates = specificDates
    }
    
    /// 类型
    func getType() -> RecurrenceRuleType {
        return type ?? .regularly
    }
    
    /// 频率
    func getFrequency() -> RepeatFrequency {
        return frequency ?? .daily
    }
    
    /// 获取有效的间隔
    func getInterval() -> Int {
        if let interval = interval, interval > 0 {
            return interval
        }
        
        return 1
    }

    /// 获取一周中的天数组
    func getWeekdaysOfTheWeek() -> [Weekday] {
        if let weekdays = daysOfTheWeek?.weekdays, weekdays.count > 0 {
            return weekdays
        }
    
        return [Weekday(date: .now)]
    }
    
    /// 获取计划的一个月中的天数组，如果不存在返回包含当前天的默认数组
    func getDaysOfTheMonth() -> [Int] {
        if let daysOfTheMonth = daysOfTheMonth, daysOfTheMonth.count > 0 {
            return daysOfTheMonth
        }
        
        let date = Date()
        return [date.day]
    }
    
    /// 获取计划的一年中的月数组，如果不存在返回包含当前月的默认数组
    func getMonthsOfTheYear() -> [Int] {
        if let monthsOfTheYear = monthsOfTheYear, monthsOfTheYear.count > 0 {
            return monthsOfTheYear
        }

        let date = Date()
        return [date.month]
    }
 
}

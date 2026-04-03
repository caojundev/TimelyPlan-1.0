//
//  RepeatDayOfWeek.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/5.
//

import Foundation

struct RepeatDayOfWeek : Codable, Hashable, Equatable {
    
    private(set) var dayOfTheWeek: Weekday
    
    private(set) var weekNumber: Int
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case dayOfTheWeek = "day"
        case weekNumber = "week"
    }
    
    init(_ dayOfTheWeek: Weekday) {
        self.init(dayOfTheWeek: dayOfTheWeek, weekNumber: 0)
    }
    
    init(dayOfTheWeek: Weekday) {
        self.init(dayOfTheWeek: dayOfTheWeek, weekNumber: 0)
    }
    
    init(dayOfTheWeek: Weekday, weekNumber: Int) {
        self.dayOfTheWeek = dayOfTheWeek
        self.weekNumber = weekNumber
    }
    
    /// 工作日
    static func weekdayDays() -> [RepeatDayOfWeek] {
        return RepeatDayOfWeek.days(for: Weekday.weekdayDays)
    }
    
    /// 周末
    static func weekendDays() -> [RepeatDayOfWeek] {
        return RepeatDayOfWeek.days(for: Weekday.weekendDays)
    }
    
    /// 根据 Weekday 数组获取对应的重复天数组
    static func days(for weekdays: [Weekday]) -> [RepeatDayOfWeek] {
        let days = weekdays.map{RepeatDayOfWeek(dayOfTheWeek: $0)}
        return days
    }
}

// MARK: - Helpers
func repeatDaysOfWeek(for weekdays: [Weekday]) -> [RepeatDayOfWeek] {
    return repeatDaysOfWeek(for: weekdays, weekNumber: 0)
}

func repeatDaysOfWeek(for weekdays: [Weekday], weekNumber: Int) -> [RepeatDayOfWeek] {
    var daysOfWeek: [RepeatDayOfWeek] = []
    for weekday in weekdays {
        let dayOfWeek = RepeatDayOfWeek(dayOfTheWeek: weekday, weekNumber: weekNumber)
        daysOfWeek.append(dayOfWeek)
    }
    
    return daysOfWeek
}

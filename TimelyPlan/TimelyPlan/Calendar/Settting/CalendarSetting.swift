//
//  CalendarSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/11.
//

import Foundation

class CalendarSetting {
    static let defaultEventDurations = [15, 30, 45, 60, 90, 120, 180]
    static let defaultEventDuration = 15
    
    static let minDaysInWeek = 2
    static let maxDaysInWeek = 7
    static let minWeeksInMonth = 2
    static let maxWeeksInMonth = 6

    enum Key: String, SettingKeyRepresentable {
        case firstWeekday
        case defaultEventDuration
        case showWeekNumber
        case showLunar
        case showChineseHolidays
        case showCompletedTask
        
        case daysInWeek
        case weeksInMonth
        
        case timedEventReminder
        case allDayEventReminder
        
        case hiddenCalendars
        case showHabit /// 显示习惯
        case habitDisplayRange /// 习惯显示范围
        
        static func keyPrefix() -> String? {
            return "CalendarSetting"
        }
    }

    @CloudStored(key: Key.firstWeekday.name, defaultValue: .monday)
    var firstWeekday: Weekday
    
    @CloudStored(key: Key.defaultEventDuration.name, defaultValue: CalendarSetting.defaultEventDuration)
    var defaultEventDuration: Int
    
    @CloudStored(key: Key.timedEventReminder.name, defaultValue: nil)
    var timedEventReminder: TaskReminder?
    
    @CloudStored(key: Key.allDayEventReminder.name, defaultValue: nil)
    var allDayEventReminder: TaskReminder?
    
    @CloudStored(key: Key.showWeekNumber.name, defaultValue: true)
    var showWeekNumber: Bool
    
    @CloudStored(key: Key.showLunar.name, defaultValue: true)
    var showLunar: Bool
    
    @CloudStored(key: Key.showChineseHolidays.name, defaultValue: true)
    var showChineseHolidays: Bool
    
    @CloudStored(key: Key.showCompletedTask.name, defaultValue: true)
    var showCompletedTask: Bool
    
    @CloudStored(key: Key.daysInWeek.name, defaultValue: 3)
    private var daysInWeek: Int
    
    @CloudStored(key: Key.weeksInMonth.name, defaultValue: 6)
    private var weeksInMonth: Int
    
    @CloudStored(key: Key.hiddenCalendars.name, defaultValue: [])
    var hiddenCalendars: [CalendarSnapshot]
    
    @CloudStored(key: Key.showHabit.name, defaultValue: true)
    var showHabit: Bool
    
    @CloudStored(key: Key.habitDisplayRange.name, defaultValue: CalendarHabitDisplayRange.todayOnly)
    var habitDisplayRange: CalendarHabitDisplayRange
    
    static let shared = CalendarSetting()
    
    private init() {}
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKeys keys: [Key]? = nil) {
        let keys = keys ?? Key.allCases
        let keyNames = keys.map { $0.name }
        KeyValueStorage.shared.addObserver(observer, forKeys: keyNames)
    }
    
    // MARK: - Public Methods
    
    func getDaysInWeek() -> Int {
        return clampedValue(daysInWeek, Self.minDaysInWeek, Self.maxDaysInWeek)
    }
    
    func setDaysInWeek(_ daysInWeek: Int) {
        let daysInWeek = clampedValue(daysInWeek, Self.minDaysInWeek, Self.maxDaysInWeek)
        if self.daysInWeek != daysInWeek {
            self.daysInWeek = daysInWeek
        }
    }
    
    func getWeeksInMonth() -> Int {
        return clampedValue(weeksInMonth, Self.minWeeksInMonth, Self.maxWeeksInMonth)
    }
    
    func setWeeksInMonth(_ weeksInMonth: Int) {
        let weeksInMonth = clampedValue(weeksInMonth, Self.minWeeksInMonth, Self.maxWeeksInMonth)
        if self.weeksInMonth != weeksInMonth {
            self.weeksInMonth = weeksInMonth
        }
    }
    
    func getDefaultEventDuration() -> Int {
        let minutes = defaultEventDuration
        return clampedValue(minutes, 15, 180)
    }
}

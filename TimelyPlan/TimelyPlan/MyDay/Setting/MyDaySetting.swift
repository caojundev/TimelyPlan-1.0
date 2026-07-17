//
//  MyDaySetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/17.
//

import Foundation

class MyDaySetting {

    enum Key: String, SettingKeyRepresentable {
        case firstWeekday
        case showLunar
        case showChineseHolidays
        case showTodo
        case showFocus
        case showHabit
        
        static func keyPrefix() -> String? {
            return "MyDaySetting"
        }
    }

    @CloudStored(key: Key.firstWeekday.name, defaultValue: .monday)
    var firstWeekday: Weekday
    
    @CloudStored(key: Key.showLunar.name, defaultValue: true)
    var showLunar: Bool
    
    @CloudStored(key: Key.showChineseHolidays.name, defaultValue: true)
    var showChineseHolidays: Bool

    @CloudStored(key: Key.showTodo.name, defaultValue: true)
    var showTodo: Bool

    @CloudStored(key: Key.showFocus.name, defaultValue: true)
    var showFocus: Bool

    @CloudStored(key: Key.showHabit.name, defaultValue: true)
    var showHabit: Bool

    static let shared = MyDaySetting()
    
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
}

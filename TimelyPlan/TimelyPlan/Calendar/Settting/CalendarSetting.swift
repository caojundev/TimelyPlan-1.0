//
//  CalendarSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/11.
//

import Foundation

class CalendarSetting {
    
    enum Key: String, SettingKeyRepresentable {
        case firstWeekday

        static func keyPrefix() -> String? {
            return "CalendarSetting"
        }
    }

    /// 周开始日
    @CloudStored(key: Key.firstWeekday.name, defaultValue: .monday)
    var firstWeekday: Weekday
    
    static let shared = CalendarSetting()
    
    private init() {}
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
}

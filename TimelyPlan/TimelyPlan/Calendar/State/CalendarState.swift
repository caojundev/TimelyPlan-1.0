//
//  CalendarState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/17.
//

import Foundation

class CalendarState {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case mode /// 当前选中模式
        
        static func keyPrefix() -> String? {
            return "CalendarState"
        }
    }
    
    @LocalStored(key: SettingKey.mode.name, defaultValue: CalendarMode.day)
    var mode: CalendarMode
    
    static let shared = CalendarState()
    private init() {}
}


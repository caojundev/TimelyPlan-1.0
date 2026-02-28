//
//  HabitSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation
import UIKit

class HabitSetting {
    
    enum Key: String, SettingKeyRepresentable {
        case firstWeekday
        case addHabitOnTop
        
        static func keyPrefix() -> String? {
            return "HabitSetting"
        }
    }

    /// 周开始日
    @CloudStored(key: Key.firstWeekday.name, defaultValue: .monday)
    var firstWeekday: Weekday
    
    /// 添加习惯到顶部
    @CloudStored(key: Key.addHabitOnTop.name, defaultValue: false)
    var addHabitOnTop: Bool
    
    static let shared = HabitSetting()
    
    private init() {}
    
}

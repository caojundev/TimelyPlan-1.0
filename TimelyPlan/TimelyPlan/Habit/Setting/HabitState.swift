//
//  HabitState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/21.
//

import Foundation

class HabitState {
    
    enum Key: String, SettingKeyRepresentable {
        case mainMenuType
        case dayTaskFilterType
        
        static func keyPrefix() -> String? {
            return "HabitState"
        }
    }

    /// 主菜单类型
    @CloudStored(key: Key.dayTaskFilterType.name, defaultValue: .day)
    var mainMenuType: HabitMainMenuType
    
    /// 天模块任务过滤类型
    @CloudStored(key: Key.dayTaskFilterType.name, defaultValue: .all)
    var dayTaskFilterType: HabitTaskFilterType
    
    static let shared = HabitState()
    
    private init() {}
    
}



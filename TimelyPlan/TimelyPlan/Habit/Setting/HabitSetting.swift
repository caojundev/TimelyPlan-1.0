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
        case customUnits /// 自定义单位
        case reasonTags  /// 原因标签
        case isReportShowArchived /// 报告是否显示已归档
        
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
    
    @CloudStored(key: Key.customUnits.name, defaultValue: [])
    var customUnits: [String]
    
    @CloudStored(key: Key.reasonTags.name, defaultValue: [])
    var reasonTags: [String]
    
    @CloudStored(key: Key.isReportShowArchived.name, defaultValue: false)
    var isReportShowArchived: Bool
    
    static let shared = HabitSetting()
    
    private init() {}
    
}

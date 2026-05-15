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
        case defaultCompletedScore
        case defaultSkippedScore
        case defaultFailedScore
        
        case isReportShowArchived /// 报告是否显示已归档
        
        case recordSortOrder /// 记录排列顺序
        
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
    
    @CloudStored(key: Key.defaultCompletedScore.name, defaultValue: kHabitDefaultCompletedScore)
    var defaultCompletedScore: Int
    
    @CloudStored(key: Key.defaultSkippedScore.name, defaultValue: kHabitDefaultSkippedScore)
    var defaultSkippedScore: Int
    
    @CloudStored(key: Key.defaultFailedScore.name, defaultValue: kHabitDefaultFailedScore)
    var defaultFailedScore: Int
    
    @CloudStored(key: Key.recordSortOrder.name, defaultValue: TPSortOrder.descending)
    var recordSortOrder: TPSortOrder
    
    static let shared = HabitSetting()
    
    private init() {}
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKeys keys: [Key]) {
        let names = keys.map { $0.name }
        KeyValueStorage.shared.addObserver(observer, forKeys: names)
    }
}

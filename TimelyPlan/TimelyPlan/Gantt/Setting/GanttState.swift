//
//  GanttState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/29.
//

import Foundation

class GanttState {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case scale /// 当前选中时间刻度
        
        static func keyPrefix() -> String? {
            return "GanttState"
        }
    }
    
    @LocalStored(key: SettingKey.scale.name, defaultValue: .day)
    var scale: GanttTimeScale.Scale
    
    static let shared = GanttState()
    private init() {}
}

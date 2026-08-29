//
//  GanttTimelineState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation

class GanttTimelineState {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case scale /// 当前选中模式
        
        static func keyPrefix() -> String? {
            return "GanttTimelineState"
        }
    }
    
    @LocalStored(key: SettingKey.scale.name, defaultValue: .day)
    var scale: GanttTimeScale.Scale
    
    static let shared = GanttTimelineState()
    private init() {}
}


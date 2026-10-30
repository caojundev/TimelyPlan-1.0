//
//  WSTimelineChartState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation

/// 甘特图组件的展示状态
class WSTimelineChartState {

    enum SettingKey: String, SettingKeyRepresentable {
        case scale /// 当前时间刻度

        static func keyPrefix() -> String? {
            return "WSTimelineChartState"
        }
    }

    /// 时间刻度，默认按天
    @LocalStored(key: SettingKey.scale.name, defaultValue: .day)
    var scale: GanttTimeScale.Scale

    static let shared = WSTimelineChartState()

    private init() {}
}

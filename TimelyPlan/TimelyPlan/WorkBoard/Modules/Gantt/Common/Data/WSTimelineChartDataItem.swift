//
//  WSTimelineChartDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的数据条目：当前时间刻度及刻度范围内的事项
struct WSTimelineChartDataItem: WSPluginDataItem {

    /// 时间刻度
    let timeScale: GanttTimeScale

    /// 当前展示日期（决定时间刻度的年份）
    let date: Date

    /// 事项
    let events: [GanttEvent]
}

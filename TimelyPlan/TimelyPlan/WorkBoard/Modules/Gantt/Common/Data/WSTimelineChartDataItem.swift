//
//  WSTimelineChartDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的数据条目：展示的时间范围及范围内的事项
struct WSTimelineChartDataItem: WSPluginDataItem {

    /// 展示的时间范围
    let timeRange: WSTimelineChartTimeRange

    /// 事项，已按顺序排列并与行数上限对齐
    let events: [GanttEvent]
}

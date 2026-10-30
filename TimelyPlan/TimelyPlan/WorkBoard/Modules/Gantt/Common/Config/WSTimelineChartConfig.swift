//
//  WSTimelineChartConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的布局配置
enum WSTimelineChartConfig {

    /// 刻度视图距离顶部的间距
    static let headerTopInset: CGFloat = 45.0

    /// 顶部刻度高度（尽量压缩，把空间留给事项）
    static let headerHeight: CGFloat = 50.0

    /// 事项行高
    static let rowHeight: CGFloat = 50.0

    /// 单位宽度。组件尺寸有限，三种刻度的密度均小于主视图
    static func pixelsPerUnit(for scale: GanttTimeScale.Scale) -> CGFloat {
        switch scale {
        case .day:
            return 80.0
        case .week:
            return 120.0
        case .month:
            return 240.0
        }
    }

    /// 刻度背景色
    static let headerBackgroundColor: UIColor = .secondarySystemGroupedBackground

    /// 事项区域背景色
    static let chartBackgroundColor: UIColor = .secondarySystemGroupedBackground

    /// 事项行背景色
    static let rowBackgroundColor: UIColor = .secondarySystemGroupedBackground

    /// 事项行交替背景色
    static let alternateRowBackgroundColor: UIColor = .secondarySystemFill

    /// 刻度分隔线颜色
    static let separatorColor = Color(light: 0xaaaaaa, dark: 0x666666, alpha: 0.1)
}

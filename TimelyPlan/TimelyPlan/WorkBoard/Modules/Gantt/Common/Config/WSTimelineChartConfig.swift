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

    /// 顶部刻度距离组件顶部的间距
    static let headerTopInset: CGFloat = 16.0

    /// 顶部刻度高度（尽量压缩，把空间留给事项）
    static let headerHeight: CGFloat = 50.0

    /// 事项行数量。事项区域高度平均分为该数量，每行显示一个事项
    static let eventRowCount: Int = 6

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

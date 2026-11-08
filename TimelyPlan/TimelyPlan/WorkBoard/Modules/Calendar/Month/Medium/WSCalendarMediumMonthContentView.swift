//
//  WSCalendarMediumMonthContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·中·双月历：本月与下月左右排列，每月占据一半宽度。
class WSCalendarMediumMonthContentView: WSCalendarMonthContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let contentInsets = UIEdgeInsets(value: 10.0)

        /// 两个月历之间的间距
        static let monthSpacing: CGFloat = 12.0
    }

    init() {
        super.init(monthCount: 2)
        contentInsets = Metrics.contentInsets
        monthSpacing = Metrics.monthSpacing
        /// 双月并排时只展示当月日期，避免两个月的相邻日期混在一起
        showsAdjacentDays = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

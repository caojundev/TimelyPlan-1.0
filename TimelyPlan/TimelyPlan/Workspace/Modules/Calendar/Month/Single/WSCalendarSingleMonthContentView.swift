//
//  WSCalendarSingleMonthContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·单月历（小尺寸）：单月网格，日期下方用小圆点展示当天的事项。
class WSCalendarSingleMonthContentView: WSCalendarMonthContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let contentInsets = UIEdgeInsets(value: 10.0)
    }

    init() {
        super.init(monthCount: 1)
        contentInsets = Metrics.contentInsets
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

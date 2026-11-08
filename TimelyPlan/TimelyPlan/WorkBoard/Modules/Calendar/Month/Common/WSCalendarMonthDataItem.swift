//
//  WSCalendarMonthDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 单月数据

/// 月历组件中单个月份的展示数据
struct WSCalendarMonthItem {

    /// 该月 1 号
    let monthDate: Date

    /// 每天的事项指示颜色，key 为日
    let dayEventColors: [Int: [UIColor]]
}

// MARK: - 组件数据

/// 月历组件的数据条目。依次展示的月份顺序与内容视图的月份顺序一致。
struct WSCalendarMonthDataItem: WSPluginDataItem {

    /// 逐月展示的数据
    let months: [WSCalendarMonthItem]

    /// 今天，用于高亮当天
    let today: Date

    init(months: [WSCalendarMonthItem], today: Date = Date()) {
        self.months = months
        self.today = today
    }
}

//
//  WSCalendarMonthEventListDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 月历 + 事项列表组件的数据条目。
struct WSCalendarMonthEventListDataItem: WSPluginDataItem {

    /// 左侧月历展示的月份，取该月 1 号
    let monthDate: Date

    /// 今天，用于高亮当天
    let today: Date

    /// 每天的事项指示颜色，key 为日
    let dayEventColors: [Int: [UIColor]]

    /// 右侧列表：本月未过去的事项，按天分组
    let dayEvents: WSCalendarDayEventsDataItem
}

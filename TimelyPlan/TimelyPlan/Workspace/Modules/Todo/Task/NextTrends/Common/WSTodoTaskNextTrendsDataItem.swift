//
//  WSTodoTaskNextTrendsDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 单天负载

/// 接下来七天中单天的任务负载
struct WSTodoTaskNextTrendsDay {

    /// 该天日期
    let date: Date

    /// 该天的任务数目
    let count: Int
}

// MARK: - 组件数据

/// 待办接下来七天组件的数据。
///
/// 只保留渲染所需的每天任务数目，柱条高度与最忙的一天由数据自行推导；
/// 另外按时间顺序保留七天的任务，供中尺寸的任务列表展示。
class WSTodoTaskNextTrendsDataItem: NSObject, WSPluginDataItem {

    /// 第一天日期，即后天
    let startDate: Date

    /// 接下来每天的任务负载，按日期顺序排列
    let days: [WSTodoTaskNextTrendsDay]

    /// 接下来七天的任务，按天与时间顺序排列
    let items: [WSTodoTaskRowItem]

    init(startDate: Date, days: [WSTodoTaskNextTrendsDay], items: [WSTodoTaskRowItem] = []) {
        self.startDate = startDate
        self.days = days
        self.items = items
        super.init()
    }

    /// 七天合计的任务数目
    var totalCount: Int {
        return days.reduce(0) { $0 + $1.count }
    }

    /// 最忙的一天，任务数相同时取更早的一天；没有任务时为 nil
    var busiestDay: WSTodoTaskNextTrendsDay? {
        var result: WSTodoTaskNextTrendsDay?
        for day in days where day.count > 0 {
            if let current = result, current.count >= day.count {
                continue
            }

            result = day
        }

        return result
    }

    /// 柱条高度比例，按最忙的一天归一化
    var dailyActivity: [Float] {
        let maxCount = days.map { $0.count }.max() ?? 0
        guard maxCount > 0 else {
            return days.map { _ in 0.0 }
        }

        return days.map { Float($0.count) / Float(maxCount) }
    }
}

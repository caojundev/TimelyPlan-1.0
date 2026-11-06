//
//  WSTodoTaskTwoDaysDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 单天任务

/// 今明两天中单天的任务
struct WSTodoTaskTwoDaysDay {

    /// 列标题：今天 / 明天
    let title: String

    /// 该天的任务，按时间排序
    let items: [WSTodoTaskRowItem]

    /// 该天的任务总数
    var totalCount: Int {
        return items.count
    }
}

// MARK: - 组件数据

/// 今明两天组件的数据
class WSTodoTaskTwoDaysDataItem: NSObject, WSPluginDataItem {

    /// 今天的任务
    let today: WSTodoTaskTwoDaysDay

    /// 明天的任务
    let tomorrow: WSTodoTaskTwoDaysDay

    /// 两天合计的任务总数
    var totalCount: Int {
        return today.totalCount + tomorrow.totalCount
    }

    init(today: WSTodoTaskTwoDaysDay, tomorrow: WSTodoTaskTwoDaysDay) {
        self.today = today
        self.tomorrow = tomorrow
        super.init()
    }
}

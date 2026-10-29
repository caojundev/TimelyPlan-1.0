//
//  WSGoalPlanInboxDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation

// MARK: - 数据条目

/// 目标收件箱组件的数据。
///
/// 只持有任务数目，展示格式由内容视图决定。
class WSGoalPlanInboxDataItem: NSObject, WSPluginDataItem {
    
    /// 收件箱任务数目
    let taskCount: Int
    
    init(taskCount: Int) {
        self.taskCount = taskCount
        super.init()
    }
}

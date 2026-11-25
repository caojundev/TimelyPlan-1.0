//
//  WSTodoTaskLargeTaskListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·自选任务列表。逐行展示所选待办任务。
class WSTodoTaskLargeTaskListPluginProvider: WSTodoTaskSelectedPluginProvider {

    init() {
        super.init(type: .TodoCustomTask.largeTaskList,
                   itemCount: WSTodoTaskItemCount.largeList,
                   layoutConfiguration: .list)
    }
}

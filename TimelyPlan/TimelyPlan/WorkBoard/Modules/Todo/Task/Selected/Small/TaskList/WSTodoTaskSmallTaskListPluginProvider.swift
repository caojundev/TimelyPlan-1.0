//
//  WSTodoTaskSmallTaskListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·小·自选任务列表。逐行展示所选待办任务。
class WSTodoTaskSmallTaskListPluginProvider: WSTodoTaskSelectedPluginProvider {

    init() {
        super.init(type: .TodoTask.smallTaskList,
                   itemCount: WSTodoTaskItemCount.smallList,
                   option: [.schedule, .step],
                   layoutConfiguration: .list)
    }
}

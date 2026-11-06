//
//  WSTodoTagLargeTasksListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·自选标签任务列表。逐行展示所选标签的未完成任务。
class WSTodoTagLargeTasksListPluginProvider: WSTodoTagTasksPluginProvider {
    
    init() {
        super.init(type: .TodoTagTask.largeList,
                   layoutConfiguration: .list(itemCount: WSTodoTaskItemCount.largeList))
    }
}

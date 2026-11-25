//
//  WSTodoSmartListLargeTasksListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·自选智能清单任务列表。逐行展示所选智能清单的未完成任务。
class WSTodoSmartListLargeTasksListPluginProvider: WSTodoSmartListTasksPluginProvider {
    
    init() {
        super.init(type: .TodoSmartListTask.largeList,
                   layoutConfiguration: .list(itemCount: WSTodoTaskItemCount.largeList))
    }
}

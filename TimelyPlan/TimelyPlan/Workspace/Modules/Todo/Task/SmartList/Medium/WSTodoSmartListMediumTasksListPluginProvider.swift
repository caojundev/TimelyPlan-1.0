//
//  WSTodoSmartListMediumTasksListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·自选智能清单任务列表。逐行展示所选智能清单的未完成任务。
class WSTodoSmartListMediumTasksListPluginProvider: WSTodoSmartListTasksPluginProvider {
    
    init() {
        super.init(type: .TodoSmartListTask.mediumList,
                   layoutConfiguration: .list(itemCount: WSTodoTaskItemCount.mediumList))
    }
}

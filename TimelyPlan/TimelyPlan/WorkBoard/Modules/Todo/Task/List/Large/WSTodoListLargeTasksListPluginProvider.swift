//
//  WSTodoListLargeTasksListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·自选清单任务列表。逐行展示所选清单的未完成任务。
class WSTodoListLargeTasksListPluginProvider: WSTodoListTasksPluginProvider {
    
    init() {
        super.init(type: .TodoListTask.largeList,
                   layoutConfiguration: .list(itemCount: WSTodoTaskItemCount.largeList))
    }
}

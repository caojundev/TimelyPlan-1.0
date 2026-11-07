//
//  WSTodoUserListMediumTasksListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·自选用户清单任务列表。逐行展示所选用户清单的未完成任务。
class WSTodoUserListMediumTasksListPluginProvider: WSTodoUserListTasksPluginProvider {
    
    init() {
        super.init(type: .TodoUserListTask.mediumList,
                   layoutConfiguration: .list(itemCount: WSTodoTaskItemCount.mediumList))
    }
}

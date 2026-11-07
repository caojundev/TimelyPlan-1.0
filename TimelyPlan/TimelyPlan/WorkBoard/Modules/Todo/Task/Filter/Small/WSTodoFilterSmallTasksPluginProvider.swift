//
//  WSTodoFilterSmallTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·小·自选过滤器任务列表。逐行展示所选过滤器的未完成任务。
class WSTodoFilterSmallTasksPluginProvider: WSTodoFilterTasksPluginProvider {
    
    init() {
        super.init(type: .TodoFilterTask.smallList,
                   layoutConfiguration: .list(itemCount: WSTodoTaskItemCount.smallList))
    }
}

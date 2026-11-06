//
//  WSTodoTagSmallTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·小·自选标签任务列表。逐行展示所选标签的未完成任务。
class WSTodoTagSmallTasksPluginProvider: WSTodoTagTasksPluginProvider {
    
    init() {
        super.init(type: .TodoTagTask.smallList,
                   layoutConfiguration: .list(itemCount: WSTodoTaskItemCount.smallList))
    }
}

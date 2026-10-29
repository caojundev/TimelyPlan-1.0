//
//  WSGoalTaskMediumTaskListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标·中·自选任务列表。逐行展示所选目标任务。
class WSGoalTaskMediumTaskListPluginProvider: WSGoalTaskRowsPluginProvider {
    
    init() {
        super.init(type: .goalMediumTaskList,
                   itemCount: WSGoalTaskItemCount.mediumTaskList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSGoalTaskListContentView(itemCount: itemCount) {
            return WSGoalTaskDetailRowView()
        }
    }
    
    override func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSGoalTaskSelectedConfigViewController(plugin: plugin,
                                                      maximumSelectionCount: itemCount)
    }
}

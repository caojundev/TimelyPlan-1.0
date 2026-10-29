//
//  WSGoalTaskSmallTaskListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标·小·自选任务列表。逐行展示所选目标任务。
class WSGoalTaskSmallTaskListPluginProvider: WSGoalTaskRowsPluginProvider {
    
    init() {
        super.init(type: .goalSmallTaskList,
                   itemCount: WSGoalTaskItemCount.smallTaskList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSGoalTaskListContentView(itemCount: itemCount) {
            return WSGoalTaskBriefRowView()
        }
    }
    
    override func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSGoalTaskSelectedConfigViewController(plugin: plugin,
                                                      maximumSelectionCount: itemCount)
    }
}

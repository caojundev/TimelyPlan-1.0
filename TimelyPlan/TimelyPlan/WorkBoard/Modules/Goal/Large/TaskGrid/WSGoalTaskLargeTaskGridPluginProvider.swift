//
//  WSGoalTaskLargeTaskGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标·大·自选任务网格。以两列网格展示所选目标任务。
class WSGoalTaskLargeTaskGridPluginProvider: WSGoalTaskRowsPluginProvider {
    
    init() {
        super.init(type: .goalLargeTaskGrid,
                   itemCount: WSGoalTaskItemCount.largeTaskGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSGoalTaskGridContentView(itemCount: itemCount,
                                         columnCount: WSGoalTaskItemCount.gridColumnCount) {
            return WSGoalTaskBriefRowView()
        }
    }
    
    override func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSGoalTaskSelectedConfigViewController(plugin: plugin,
                                                      maximumSelectionCount: itemCount)
    }
}

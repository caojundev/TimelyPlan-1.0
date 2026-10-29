//
//  WSGoalTaskMediumTaskGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标·中·自选任务网格。以两列网格展示所选目标任务。
class WSGoalTaskMediumTaskGridPluginProvider: WSGoalTaskRowsPluginProvider {
    
    init() {
        super.init(type: .goalMediumTaskGrid,
                   itemCount: WSGoalTaskItemCount.mediumTaskGrid)
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

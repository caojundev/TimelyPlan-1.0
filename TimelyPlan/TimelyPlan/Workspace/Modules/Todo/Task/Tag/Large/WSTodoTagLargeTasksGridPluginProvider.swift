//
//  WSTodoTagLargeTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·自选标签任务网格。以两列网格展示所选标签的未完成任务。
class WSTodoTagLargeTasksGridPluginProvider: WSTodoTagTasksPluginProvider {
    
    init() {
        super.init(type: .TodoTagTask.largeGrid,
                   layoutConfiguration: .grid(itemCount: WSTodoTaskItemCount.largeGrid,
                                              columnCount: WSTodoTaskItemCount.gridColumnCount))
    }
}

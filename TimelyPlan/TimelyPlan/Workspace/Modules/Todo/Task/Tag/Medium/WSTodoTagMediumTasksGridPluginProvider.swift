//
//  WSTodoTagMediumTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·自选标签任务网格。以两列网格展示所选标签的未完成任务。
class WSTodoTagMediumTasksGridPluginProvider: WSTodoTagTasksPluginProvider {
    
    init() {
        super.init(type: .TodoTagTask.mediumGrid,
                   layoutConfiguration: .grid(itemCount: WSTodoTaskItemCount.mediumGrid,
                                              columnCount: WSTodoTaskItemCount.gridColumnCount))
    }
}

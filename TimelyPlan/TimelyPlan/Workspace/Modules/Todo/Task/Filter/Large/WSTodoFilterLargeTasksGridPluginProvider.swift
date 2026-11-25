//
//  WSTodoFilterLargeTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·自选过滤器任务网格。以两列网格展示所选过滤器的未完成任务。
class WSTodoFilterLargeTasksGridPluginProvider: WSTodoFilterTasksPluginProvider {
    
    init() {
        super.init(type: .TodoFilterTask.largeGrid,
                   layoutConfiguration: .grid(itemCount: WSTodoTaskItemCount.largeGrid,
                                              columnCount: WSTodoTaskItemCount.gridColumnCount))
    }
}

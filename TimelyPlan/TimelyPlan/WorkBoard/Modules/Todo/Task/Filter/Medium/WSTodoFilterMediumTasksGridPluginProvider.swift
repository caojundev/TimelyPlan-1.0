//
//  WSTodoFilterMediumTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·自选过滤器任务网格。以两列网格展示所选过滤器的未完成任务。
class WSTodoFilterMediumTasksGridPluginProvider: WSTodoFilterTasksPluginProvider {
    
    init() {
        super.init(type: .TodoFilterTask.mediumGrid,
                   layoutConfiguration: .grid(itemCount: WSTodoTaskItemCount.mediumGrid,
                                              columnCount: WSTodoTaskItemCount.gridColumnCount))
    }
}

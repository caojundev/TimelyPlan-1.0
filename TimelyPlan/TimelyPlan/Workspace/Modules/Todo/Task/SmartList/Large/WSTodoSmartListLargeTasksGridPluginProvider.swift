//
//  WSTodoSmartListLargeTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·自选智能清单任务网格。以两列网格展示所选智能清单的未完成任务。
class WSTodoSmartListLargeTasksGridPluginProvider: WSTodoSmartListTasksPluginProvider {
    
    init() {
        super.init(type: .TodoSmartListTask.largeGrid,
                   layoutConfiguration: .grid(itemCount: WSTodoTaskItemCount.largeGrid,
                                              columnCount: WSTodoTaskItemCount.gridColumnCount))
    }
}

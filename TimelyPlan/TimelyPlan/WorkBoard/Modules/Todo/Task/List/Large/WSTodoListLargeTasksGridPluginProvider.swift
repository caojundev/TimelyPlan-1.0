//
//  WSTodoListLargeTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·自选清单任务网格。以两列网格展示所选清单的未完成任务。
class WSTodoListLargeTasksGridPluginProvider: WSTodoListTasksPluginProvider {
    
    init() {
        super.init(type: .TodoListTask.largeGrid,
                   layoutConfiguration: .grid(itemCount: WSTodoTaskItemCount.largeGrid,
                                              columnCount: WSTodoTaskItemCount.gridColumnCount))
    }
}

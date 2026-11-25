//
//  WSTodoUserListLargeTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·自选用户清单任务网格。以两列网格展示所选用户清单的未完成任务。
class WSTodoUserListLargeTasksGridPluginProvider: WSTodoUserListTasksPluginProvider {
    
    init() {
        super.init(type: .TodoUserListTask.largeGrid,
                   layoutConfiguration: .grid(itemCount: WSTodoTaskItemCount.largeGrid,
                                              columnCount: WSTodoTaskItemCount.gridColumnCount))
    }
}

//
//  WSTodoTaskMediumTaskGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·自选任务网格。以两列网格展示所选待办任务。
class WSTodoTaskMediumTaskGridPluginProvider: WSTodoTaskSelectedPluginProvider {

    init() {
        super.init(type: .TodoTask.mediumTaskGrid,
                   itemCount: WSTodoTaskItemCount.mediumGrid,
                   option: [.schedule, .step],
                   layoutConfiguration: .grid(columnCount: WSTodoTaskItemCount.gridColumnCount))
    }
}

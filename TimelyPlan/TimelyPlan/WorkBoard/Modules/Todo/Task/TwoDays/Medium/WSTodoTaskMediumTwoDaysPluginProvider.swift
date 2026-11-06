//
//  WSTodoTaskMediumTwoDaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·今明两天。按今天、明天两列展示任务。
class WSTodoTaskMediumTwoDaysPluginProvider: WSTodoTaskTwoDaysPluginProvider {

    init() {
        super.init(type: .TodoTask.mediumTwoDays,
                   itemCount: WSTodoTaskTwoDaysLayout.maximumRowCount)
    }
}

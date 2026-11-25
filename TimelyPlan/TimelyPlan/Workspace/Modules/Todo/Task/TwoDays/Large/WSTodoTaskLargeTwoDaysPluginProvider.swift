//
//  WSTodoTaskLargeTwoDaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·今明两天。按今天、明天两列展示任务。
class WSTodoTaskLargeTwoDaysPluginProvider: WSTodoTaskTwoDaysPluginProvider {

    init() {
        super.init(type: .TodoSmartListTask.largeTwoDays,
                   itemCount: WSTodoTaskTwoDaysLayout.largeRowCount)
    }
}

//
//  WSGoalPlanSmallPlanListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标·小·计划列表。逐行展示进行中的目标计划。
class WSGoalPlanSmallPlanListPluginProvider: WSGoalPlanListPluginProvider {
    
    init() {
        super.init(type: .goalSmallPlanList,
                   itemCount: WSGoalPlanItemCount.smallPlanList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSGoalPlanListContentView(itemCount: itemCount)
    }
}

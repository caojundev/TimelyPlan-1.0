//
//  WSGoalPlanMediumPlanGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标·中·计划网格。以两列网格展示进行中的目标计划。
class WSGoalPlanMediumPlanGridPluginProvider: WSGoalPlanRowsPluginProvider {
    
    init() {
        super.init(type: .goalMediumPlanGrid,
                   itemCount: WSGoalPlanItemCount.mediumPlanGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSGoalPlanGridContentView(itemCount: itemCount,
                                         columnCount: WSGoalPlanItemCount.gridColumnCount) {
            return WSGoalPlanBriefRowView()
        }
    }
}

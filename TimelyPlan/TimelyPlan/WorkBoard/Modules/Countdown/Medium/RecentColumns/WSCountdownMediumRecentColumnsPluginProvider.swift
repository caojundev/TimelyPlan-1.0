//
//  WSCountdownMediumRecentColumnsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·中·最近（三列）。以一行三列的竖排卡片展示距离当前日期最近的三个倒数日事项。
class WSCountdownMediumRecentColumnsPluginProvider: WSCountdownRecentPluginProvider {
    
    init() {
        super.init(type: .countdownMediumRecentColumns,
                   cellClass: WSCountdownMediumRecentColumnsPluginCell.self,
                   itemCount: WSCountdownRecentItemCount.mediumColumns)
    }
}

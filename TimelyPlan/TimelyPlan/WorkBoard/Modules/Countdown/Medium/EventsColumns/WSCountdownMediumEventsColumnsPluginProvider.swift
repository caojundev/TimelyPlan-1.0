//
//  WSCountdownMediumEventsColumnsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·中·事项（三列）。以一行三列的竖排卡片展示最近或用户自选的三个倒数日事项。
class WSCountdownMediumEventsColumnsPluginProvider: WSCountdownEventsPluginProvider {
    
    init() {
        super.init(type: .countdownMediumEventsColumns,
                   cellClass: WSCountdownMediumEventsColumnsPluginCell.self,
                   itemCount: WSCountdownEventsItemCount.mediumColumns)
    }
}

//
//  WSCountdownMediumRecentGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·中·最近（网格）。以两列两行的网格展示距离当前日期最近的四个倒数日事项。
class WSCountdownMediumRecentGridPluginProvider: WSCountdownRecentPluginProvider {
    
    init() {
        super.init(type: .countdownMediumRecentGrid,
                   cellClass: WSCountdownMediumRecentGridPluginCell.self,
                   itemCount: WSCountdownRecentItemCount.mediumGrid)
    }
}

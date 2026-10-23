//
//  WSCountdownLargeRecentGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·大·最近（网格）。以两列四行的网格展示距离当前日期最近的八个倒数日事项。
class WSCountdownLargeRecentGridPluginProvider: WSCountdownRecentPluginProvider {
    
    init() {
        super.init(type: .countdownLargeRecentGrid,
                   cellClass: WSCountdownLargeRecentGridPluginCell.self,
                   itemCount: WSCountdownRecentItemCount.largeGrid)
    }
}

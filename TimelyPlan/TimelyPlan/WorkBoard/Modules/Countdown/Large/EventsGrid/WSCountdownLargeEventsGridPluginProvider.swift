//
//  WSCountdownLargeEventsGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·大·事项（网格）。以两列四行的网格展示最近或用户自选的八个倒数日事项。
class WSCountdownLargeEventsGridPluginProvider: WSCountdownEventsPluginProvider {
    
    init() {
        super.init(type: .countdownLargeEventsGrid,
                   cellClass: WSCountdownLargeEventsGridPluginCell.self,
                   itemCount: WSCountdownEventsItemCount.largeGrid)
    }
}

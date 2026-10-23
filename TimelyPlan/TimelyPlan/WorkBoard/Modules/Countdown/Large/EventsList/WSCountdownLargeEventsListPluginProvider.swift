//
//  WSCountdownLargeEventsListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·大·事项（列表）。逐行展示最近或用户自选的五个倒数日事项。
class WSCountdownLargeEventsListPluginProvider: WSCountdownEventsPluginProvider {
    
    init() {
        super.init(type: .countdownLargeEventsList,
                   cellClass: WSCountdownLargeEventsListPluginCell.self,
                   itemCount: WSCountdownEventsItemCount.largeList)
    }
}

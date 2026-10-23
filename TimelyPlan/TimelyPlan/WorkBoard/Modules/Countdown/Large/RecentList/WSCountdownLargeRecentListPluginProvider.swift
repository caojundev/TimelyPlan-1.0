//
//  WSCountdownLargeRecentListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·大·最近（列表）。逐行展示距离当前日期最近的五个倒数日事项。
class WSCountdownLargeRecentListPluginProvider: WSCountdownRecentPluginProvider {
    
    init() {
        super.init(type: .countdownLargeRecentList,
                   cellClass: WSCountdownLargeRecentListPluginCell.self,
                   itemCount: WSCountdownRecentItemCount.largeList)
    }
}

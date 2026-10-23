//
//  WSCountdownMediumRecentListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/21.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·中·最近（列表）。逐行展示距离当前日期最近的三个倒数日事项。
class WSCountdownMediumRecentListPluginProvider: WSCountdownRecentPluginProvider {
    
    init() {
        super.init(type: .countdownMediumRecentList,
                   cellClass: WSCountdownMediumRecentListPluginCell.self,
                   itemCount: WSCountdownRecentItemCount.mediumList)
    }
}

//
//  WSCountdownSmallRecentPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·小·最近。展示距离当前日期最近的两个倒数日事项。
class WSCountdownSmallRecentPluginProvider: WSCountdownRecentPluginProvider {
    
    init() {
        super.init(type: .countdownSmallRecent,
                   cellClass: WSCountdownSmallRecentPluginCell.self,
                   itemCount: WSCountdownRecentItemCount.small)
    }
}

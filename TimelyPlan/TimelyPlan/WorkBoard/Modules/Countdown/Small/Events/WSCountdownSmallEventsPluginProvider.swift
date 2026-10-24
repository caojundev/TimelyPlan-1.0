//
//  WSCountdownSmallEventsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·小·事项。展示最近或用户自选的两个倒数日事项。
class WSCountdownSmallEventsPluginProvider: WSCountdownEventsPluginProvider {
    
    init() {
        super.init(type: .countdownSmallEvents,
                   itemCount: WSCountdownEventsItemCount.small)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSCountdownEventsCardContentView(itemCount: itemCount, columnCount: 1)
    }
}

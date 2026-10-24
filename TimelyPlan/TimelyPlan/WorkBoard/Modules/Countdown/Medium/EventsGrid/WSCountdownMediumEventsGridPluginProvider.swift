//
//  WSCountdownMediumEventsGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·中·事项（网格）。以两列两行的网格展示最近或用户自选的四个倒数日事项。
class WSCountdownMediumEventsGridPluginProvider: WSCountdownEventsPluginProvider {
    
    init() {
        super.init(type: .countdownMediumEventsGrid,
                   itemCount: WSCountdownEventsItemCount.mediumGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSCountdownEventsCardContentView(itemCount: itemCount, columnCount: 2)
    }
}

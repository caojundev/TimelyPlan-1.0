//
//  WSCountdownMediumEventsListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/21.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·中·事项（列表）。逐行展示最近或用户自选的三个倒数日事项。
class WSCountdownMediumEventsListPluginProvider: WSCountdownEventsPluginProvider {
    
    init() {
        super.init(type: .countdownMediumEventsList,
                   itemCount: WSCountdownEventsItemCount.mediumList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSCountdownEventsContentView(itemCount: itemCount)
    }
}

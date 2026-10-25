//
//  WSFocusMediumUserTimerListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·中·用户计时器（列表）。纵向展示用户自选的三个计时器。
class WSFocusMediumUserTimerListPluginProvider: WSFocusUserTimersPluginProvider {
    
    init() {
        super.init(type: .focusMediumUserTimerList,
                   itemCount: WSFocusUserTimerItemCount.mediumList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSFocusUserTimerListContentView(itemCount: itemCount)
    }
}

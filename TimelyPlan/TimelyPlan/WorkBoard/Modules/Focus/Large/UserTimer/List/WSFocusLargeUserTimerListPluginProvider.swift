//
//  WSFocusLargeUserTimerListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·大·用户计时器（列表）。纵向展示用户自选的五个计时器。
class WSFocusLargeUserTimerListPluginProvider: WSFocusUserTimersPluginProvider {
    
    init() {
        super.init(type: .focusLargeUserTimerList,
                   itemCount: WSFocusUserTimerItemCount.largeList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSFocusUserTimerListContentView(itemCount: itemCount)
    }
}

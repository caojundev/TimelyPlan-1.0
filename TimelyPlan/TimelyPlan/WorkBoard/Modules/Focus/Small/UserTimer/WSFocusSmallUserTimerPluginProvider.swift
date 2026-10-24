//
//  WSFocusSmallUserTimerPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·小·用户计时器。展示用户自选的两个计时器。
class WSFocusSmallUserTimerPluginProvider: WSFocusUserTimersPluginProvider {
    
    init() {
        super.init(type: .focusSmallUserTimer,
                   itemCount: WSFocusUserTimerItemCount.small)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSFocusSmallUserTimerContentView(itemCount: itemCount)
    }
}

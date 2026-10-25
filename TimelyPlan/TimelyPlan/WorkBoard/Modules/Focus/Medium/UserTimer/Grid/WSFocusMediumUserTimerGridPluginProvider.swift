//
//  WSFocusMediumUserTimerGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·中·用户计时器（网格）。以两列两行的网格展示用户自选的四个计时器。
class WSFocusMediumUserTimerGridPluginProvider: WSFocusUserTimersPluginProvider {
    
    private enum Metrics {
        
        /// 每行卡片数
        static let columnCount = 2
    }
    
    init() {
        super.init(type: .focusMediumUserTimerGrid,
                   itemCount: WSFocusUserTimerItemCount.mediumGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSFocusUserTimerGridContentView(itemCount: itemCount,
                                               columnCount: Metrics.columnCount)
    }
}

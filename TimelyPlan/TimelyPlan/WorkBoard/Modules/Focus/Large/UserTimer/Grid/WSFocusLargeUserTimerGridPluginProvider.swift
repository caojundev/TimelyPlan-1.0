//
//  WSFocusLargeUserTimerGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·大·用户计时器（网格）。以两列六行的网格展示用户自选的十二个计时器。
class WSFocusLargeUserTimerGridPluginProvider: WSFocusUserTimersPluginProvider {
    
    private enum Metrics {
        
        /// 每行卡片数
        static let columnCount = 2
    }
    
    init() {
        super.init(type: .focusLargeUserTimerGrid,
                   itemCount: WSFocusUserTimerItemCount.largeGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSFocusUserTimerGridContentView(itemCount: itemCount,
                                               columnCount: Metrics.columnCount)
    }
}

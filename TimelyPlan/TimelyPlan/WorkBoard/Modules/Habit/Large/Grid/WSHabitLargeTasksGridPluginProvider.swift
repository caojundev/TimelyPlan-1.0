//
//  WSHabitLargeTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·大·任务网格。以两列四行的卡片展示今日排期的八个习惯任务。
class WSHabitLargeTasksGridPluginProvider: WSHabitTasksPluginProvider {
    
    private enum Metrics {
        
        /// 每行卡片数
        static let columnCount = 2
    }
    
    init() {
        super.init(type: .habitLargeTasksGrid,
                   itemCount: WSHabitTaskItemCount.largeGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitTaskGridContentView(itemCount: itemCount,
                                          columnCount: Metrics.columnCount)
    }
}

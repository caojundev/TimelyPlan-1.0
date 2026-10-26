//
//  WSHabitMediumTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·中·任务网格。以两列两行的卡片展示今日排期的四个习惯任务。
class WSHabitMediumTasksGridPluginProvider: WSHabitTasksPluginProvider {
    
    private enum Metrics {
        
        /// 每行卡片数
        static let columnCount = 2
    }
    
    init() {
        super.init(type: .habitMediumTasksGrid,
                   itemCount: WSHabitTaskItemCount.mediumGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitTaskGridContentView(itemCount: itemCount,
                                          columnCount: Metrics.columnCount)
    }
}

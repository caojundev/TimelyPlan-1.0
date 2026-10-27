//
//  WSHabitSmallTasksGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·小·任务网格。以两列两行展示今日排期的四个习惯图标。
class WSHabitSmallTasksGridPluginProvider: WSHabitTasksPluginProvider {
    
    private enum Metrics {
        
        /// 每行图标数
        static let columnCount = 2
    }
    
    init() {
        super.init(type: .habitSmallTasksGrid,
                   itemCount: WSHabitTaskItemCount.smallGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitSmallGridContentView(itemCount: itemCount,
                                           columnCount: Metrics.columnCount)
    }
}

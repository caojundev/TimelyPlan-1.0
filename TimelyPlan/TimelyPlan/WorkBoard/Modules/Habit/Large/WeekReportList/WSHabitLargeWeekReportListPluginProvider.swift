//
//  WSHabitLargeWeekReportListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·大·周报告列表。纵向展示今日排期习惯本周的完成情况。
class WSHabitLargeWeekReportListPluginProvider: WSHabitTasksPluginProvider {
    
    init() {
        super.init(type: .habitLargeWeekReportList,
                   itemCount: WSHabitTaskItemCount.largeList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitWeekReportListContentView(itemCount: itemCount)
    }
    
    override func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSHabitWeekReportListContentInteractor(plugin: plugin,
                                                      context: context,
                                                      maximumItemCount: itemCount)
    }
}

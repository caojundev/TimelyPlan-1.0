//
//  WSHabitLargeTasksListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·大·任务列表。纵向展示今日排期的六个习惯任务。
class WSHabitLargeTasksListPluginProvider: WSHabitTasksPluginProvider {
    
    init() {
        super.init(type: .habitLargeTasksList,
                   itemCount: WSHabitTaskItemCount.largeList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitTaskListContentView(itemCount: itemCount)
    }
}

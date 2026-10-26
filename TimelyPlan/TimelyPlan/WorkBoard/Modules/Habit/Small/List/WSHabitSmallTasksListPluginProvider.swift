//
//  WSHabitSmallTasksListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·小·任务。逐行展示今日排期的习惯任务。
class WSHabitSmallTasksListPluginProvider: WSHabitTasksPluginProvider {
    
    init() {
        super.init(type: .habitSmallTasks,
                   itemCount: WSHabitTaskItemCount.small)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitTaskListContentView(itemCount: itemCount)
    }
}

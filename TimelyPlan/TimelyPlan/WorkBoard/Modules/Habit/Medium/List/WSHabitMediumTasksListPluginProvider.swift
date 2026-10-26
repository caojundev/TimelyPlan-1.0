//
//  WSHabitMediumTasksListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·中·任务列表。纵向展示今日排期的三个习惯任务。
class WSHabitMediumTasksListPluginProvider: WSHabitTasksPluginProvider {
    
    init() {
        super.init(type: .habitMediumTasksList,
                   itemCount: WSHabitTaskItemCount.mediumList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitTaskListContentView(itemCount: itemCount)
    }
}

//
//  WSHabitMediumMonthActivityListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·中·本月活动列表。纵向展示今日排期习惯本月每天的活动。
class WSHabitMediumMonthActivityListPluginProvider: WSHabitTasksPluginProvider {
    
    init() {
        super.init(type: .habitMediumMonthActivityList,
                   itemCount: WSHabitTaskItemCount.mediumMonthActivityList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitMonthActivityListContentView(itemCount: itemCount)
    }
    
    override func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSHabitMonthActivityListContentInteractor(plugin: plugin,
                                                         context: context,
                                                         maximumItemCount: itemCount)
    }
}

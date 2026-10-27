//
//  WSHabitWeekPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·中·周进度。展示所选习惯本周七天的状态与进度。
class WSHabitWeekPluginProvider: WSHabitPeriodPluginProvider {
    
    init() {
        super.init(type: .habitMediumWeek, itemCount: 1)
    }
    
    override func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSHabitWeekContentInteractor(plugin: plugin, context: context)
    }
}

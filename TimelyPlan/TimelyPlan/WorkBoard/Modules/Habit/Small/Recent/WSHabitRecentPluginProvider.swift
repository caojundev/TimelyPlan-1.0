//
//  WSHabitRecentPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·小·最近三天。展示所选习惯最近三天的状态与进度。
class WSHabitRecentPluginProvider: WSHabitPeriodPluginProvider {
    
    init() {
        super.init(type: .habitSmallRecent, itemCount: 1)
    }
    
    override func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSHabitRecentContentInteractor(plugin: plugin, context: context)
    }
}

//
//  WSHabitWeekPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·中·周进度。展示今日首个习惯本周七天的状态与进度。
class WSHabitWeekPluginProvider: WSHabitTasksPluginProvider {
    
    init() {
        super.init(type: .habitMediumWeek, itemCount: 1)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitWeekContentView()
    }
    
    override func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSHabitWeekContentInteractor(plugin: plugin, context: context)
    }
    
    /// 复用自选习惯的配置界面
    override func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSHabitSelectedConfigViewController(plugin: plugin)
    }
    
    override func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No Habit")
        return configuration
    }
}

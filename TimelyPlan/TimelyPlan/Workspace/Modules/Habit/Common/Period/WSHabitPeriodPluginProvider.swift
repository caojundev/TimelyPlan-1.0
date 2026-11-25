//
//  WSHabitPeriodPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 以若干天为单位展示习惯的组件提供者基类。
///
/// 内容视图、配置界面与空白态统一在此提供，子类只需声明类型与内容交互器。
class WSHabitPeriodPluginProvider: WSHabitTasksPluginProvider {
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitPeriodContentView()
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

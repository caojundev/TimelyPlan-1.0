//
//  WSHabitSmallTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 习惯任务组件的展示条数。
enum WSHabitTaskItemCount {
    
    /// 小号组件的展示条数
    static let small = 3
}

// MARK: - 组件提供者

/// 习惯·小·任务。逐行展示今日排期的习惯任务。
///
/// 取数与交互由 `WSHabitTaskContentInteractor` 统一提供，内容视图只负责渲染：
/// 展示顺序、完成进度与状态均与习惯首页的列表保持一致。
class WSHabitSmallTasksPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType = .habitSmallTasks
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSHabitTaskListContentView(itemCount: WSHabitTaskItemCount.small)
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSHabitTaskContentInteractor(plugin: plugin,
                                            context: context,
                                            maximumItemCount: WSHabitTaskItemCount.small)
    }
    
    /// 今日没有排期任务时，沿用习惯模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No Habit Today")
        return configuration
    }
}

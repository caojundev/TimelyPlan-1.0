//
//  WSGoalPlanSmallPlanRingPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标·小·自选双环。内环展示任务进度、外环展示时间进度。
class WSGoalPlanSmallPlanRingPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .goalSmallPlanRing
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .small
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSGoalPlanSmallPlanRingContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSGoalPlanSelectedContentInteractor(plugin: plugin, context: context)
    }
    
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSGoalPlanSelectedConfigViewController(plugin: plugin)
    }
    
    /// 未选择目标计划时提示配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "target"
        configuration.title = resGetString("No Goal Selected")
        return configuration
    }
}

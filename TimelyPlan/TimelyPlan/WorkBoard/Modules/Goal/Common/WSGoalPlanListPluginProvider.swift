//
//  WSGoalPlanListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 目标计划组件的展示条数。
enum WSGoalPlanItemCount {
    
    /// 小号列表组件的展示条数
    static let smallPlanList = 2
}

// MARK: - 组件提供者基类

/// 目标计划列表组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 展示条数 + 内容视图」，取数与交互由基类统一提供。
class WSGoalPlanListPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 最多展示的目标计划数目
    let itemCount: Int
    
    init(type: WSPluginType, itemCount: Int) {
        self.type = type
        self.itemCount = itemCount
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return type.size
    }
    
    /// 内容视图由各尺寸子类提供
    func makeContentView() -> WSPluginContentView {
        fatalError("Subclass must override makeContentView()")
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSGoalPlanListContentInteractor(plugin: plugin,
                                               context: context,
                                               maximumItemCount: itemCount)
    }
    
    /// 没有进行中的目标计划时，沿用目标模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "target"
        configuration.title = resGetString("No Goal")
        return configuration
    }
}

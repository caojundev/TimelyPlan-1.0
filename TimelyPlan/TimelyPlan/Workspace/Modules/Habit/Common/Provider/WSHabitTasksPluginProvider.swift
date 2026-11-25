//
//  WSHabitTasksPluginProvider.swift
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
    
    /// 小号网格组件的展示条数
    static let smallGrid = 4
    
    /// 中号列表组件的展示条数
    static let mediumList = 3
    
    /// 中号月活动状态列表组件
    static let mediumMonthActivityList = 2
    
    /// 中号网格组件的展示条数
    static let mediumGrid = 4
    
    /// 大号列表组件的展示条数
    static let largeList = 6
    
    /// 大号月活动状态列表组件
    static let largeMonthActivityList = 4
    
    /// 大号网格组件的展示条数
    static let largeGrid = 8
}

// MARK: - 组件提供者基类

/// 习惯任务组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 展示条数 + 内容视图」，取数与交互由基类统一提供。
class WSHabitTasksPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 最多展示的习惯任务数目
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
        return WSHabitTaskContentInteractor(plugin: plugin,
                                            context: context,
                                            maximumItemCount: itemCount)
    }
    
    /// 今日没有排期任务时，沿用习惯模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No Habit Today")
        return configuration
    }
    
    /// 默认不支持配置，需要配置的组件在子类中覆写
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return nil
    }
}

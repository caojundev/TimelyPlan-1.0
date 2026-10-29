//
//  WSGoalTaskRowsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 目标任务组件的展示条数。
enum WSGoalTaskItemCount {
    
    /// 小号列表组件的展示条数，同时也是最多可选的任务数目
    static let smallTaskList = 3
}

// MARK: - 组件提供者基类

/// 目标任务行组件提供者基类。
///
/// 各尺寸列表 / 网格组件只需声明「类型 + 展示条数 + 内容视图」，取数与交互由基类统一提供。
class WSGoalTaskRowsPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 最多展示的目标任务数目
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
        return WSGoalTaskRowsContentInteractor(plugin: plugin,
                                               context: context,
                                               maximumItemCount: itemCount)
    }
    
    /// 未选择目标任务时提示配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No Task Selected")
        return configuration
    }
    
    
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return nil
    }
}

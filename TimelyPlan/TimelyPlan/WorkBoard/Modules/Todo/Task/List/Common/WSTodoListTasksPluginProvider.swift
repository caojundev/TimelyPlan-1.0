//
//  WSTodoListTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 待办自选清单任务组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 布局」，取数、交互与配置由基类统一提供。
class WSTodoListTasksPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 内容视图的布局配置
    let layoutConfiguration: WSTodoListTasksContentView.LayoutConfiguration
    
    init(type: WSPluginType, layoutConfiguration: WSTodoListTasksContentView.LayoutConfiguration) {
        self.type = type
        self.layoutConfiguration = layoutConfiguration
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return type.size
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSTodoListTasksContentView(layoutConfiguration: layoutConfiguration)
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTodoListTasksContentInteractor(plugin: plugin,
                                                context: context,
                                                maximumItemCount: layoutConfiguration.itemCount,
                                                option: [.schedule, .step])
    }
    
    /// 未选择清单时提示配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No List Selected")
        return configuration
    }
    
    /// 由用户单选要展示的清单
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSTodoListSingleSelectionConfigViewController(plugin: plugin)
    }
}

//
//  WSTodoGroupTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 按集合筛选任务组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 布局」，取数与配置界面由各业务子类提供。
class WSTodoGroupTasksPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 内容视图的布局配置
    let layoutConfiguration: WSTodoGroupTasksContentView.LayoutConfiguration
    
    init(type: WSPluginType,
         layoutConfiguration: WSTodoGroupTasksContentView.LayoutConfiguration) {
        self.type = type
        self.layoutConfiguration = layoutConfiguration
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return type.size
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSTodoGroupTasksContentView(layoutConfiguration: layoutConfiguration)
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        fatalError("Subclass must override makeContentInteractor(plugin:context:)")
    }
    
    /// 未选择集合时提示配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "plugin_todo_list_32"
        return configuration
    }
    
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        fatalError("Subclass must override makeConfigViewController(plugin:)")
    }
}

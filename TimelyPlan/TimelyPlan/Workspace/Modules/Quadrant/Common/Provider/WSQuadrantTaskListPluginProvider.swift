//
//  WSQuadrantTaskListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/28.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 单象限任务列表组件提供者基类。
///
/// 三个尺寸共用「未选择象限」的空白提示与配置入口，子类只需提供类型、内容视图与内容交互器。
class WSQuadrantTaskListPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    init(type: WSPluginType) {
        self.type = type
    }
    
    /// 内容视图由各尺寸子类提供
    func makeContentView() -> WSPluginContentView {
        fatalError("Subclass must override makeContentView()")
    }
    
    /// 内容交互器由各尺寸子类提供
    func makeContentInteractor(plugin: WSPlugin,
                               context: WSPluginContext) -> WSPluginContentInteractor {
        fatalError("Subclass must override makeContentInteractor(plugin:context:)")
    }
    
    /// 未选择象限时，与其它未配置的组件一致展示空白占位
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "plugin_empty_quadrant_32"
        configuration.title = resGetString("No Quadrant Selected")
        return configuration
    }
    
    /// 配置界面：选择要展示的象限
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSQuadrantTaskConfigViewController(plugin: plugin)
    }
}

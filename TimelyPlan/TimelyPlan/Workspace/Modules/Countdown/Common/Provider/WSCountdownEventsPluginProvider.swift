//
//  WSCountdownEventsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 倒数日「事项」类组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 展示条数 + 内容视图」，取数、行内点击详情与配置入口
/// 等行为由基类统一提供。展示内容由配置决定：默认最近事项，也可切换为自选事项。
class WSCountdownEventsPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 最多展示的事项数目
    let itemCount: Int
    
    /// 初始化提供者
    /// - Parameters:
    ///   - type: 插件类型
    ///   - itemCount: 最多展示的事项数目
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
        return WSCountdownEventsContentInteractor(plugin: plugin,
                                                  context: context,
                                                  maximumItemCount: itemCount)
    }
    
    /// 所有尺寸共用同一套配置界面，展示内容由配置中的来源决定
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSCountdownEventsConfigViewController(plugin: plugin)
    }
}

//
//  WSFocusUserTimersPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 用户计时器组件的展示条数。
enum WSFocusUserTimerItemCount {
    
    /// 小号组件的展示条数
    static let small = 3
}

// MARK: - 组件提供者基类

/// 用户计时器组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 展示条数 + 内容视图」，取数、行内开启专注与配置入口
/// 等行为由基类统一提供。展示内容由配置决定：默认取最近的活动计时器，
/// 也可切换为用户自选的计时器。
class WSFocusUserTimersPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 最多展示的计时器数目
    let itemCount: Int
    
    /// 初始化提供者
    /// - Parameters:
    ///   - type: 插件类型
    ///   - itemCount: 最多展示的计时器数目
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
        return WSFocusUserTimerContentInteractor(plugin: plugin,
                                                 context: context,
                                                 maximumItemCount: itemCount)
    }
    
    /// 各尺寸共用同一套配置界面，展示内容由配置中选择的计时器决定
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSFocusUserTimerConfigViewController(plugin: plugin)
    }
}

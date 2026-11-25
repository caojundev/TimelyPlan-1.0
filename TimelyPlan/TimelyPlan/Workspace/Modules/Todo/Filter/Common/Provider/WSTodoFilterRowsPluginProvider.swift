//
//  WSTodoFilterRowsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 待办过滤器组件的展示条数。
enum WSTodoFilterItemCount {
    
    /// 小号列表组件的展示条数
    static let smallList = 3
    
    /// 中号列表组件的展示条数
    static let mediumList = 3
    
    /// 大号列表组件的展示条数
    static let largeList = 6
    
    /// 中号网格组件的展示条数
    static let mediumGrid = 4
    
    /// 大号网格组件的展示条数
    static let largeGrid = 8
    
    /// 网格组件的列数
    static let gridColumnCount = 2
}

// MARK: - 组件提供者基类

/// 待办过滤器行组件提供者基类。
///
/// 各尺寸列表 / 网格组件只需声明「类型 + 展示条数 + 内容视图」，取数与交互由基类统一提供。
class WSTodoFilterRowsPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 最多展示的过滤器数目
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
        return WSTodoFilterRowsContentInteractor(plugin: plugin,
                                                 context: context,
                                                 maximumItemCount: itemCount)
    }
    
    /// 没有过滤器时，沿用待办模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "line.3.horizontal.decrease"
        configuration.title = resGetString("No Filter")
        return configuration
    }
    
    /// 由用户选择要展示的过滤器，最多可选择与展示条数相同的数目
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSTodoFilterSelectedConfigViewController(plugin: plugin,
                                                        maximumSelectionCount: itemCount)
    }
}

//
//  TodoListRowsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 待办清单组件的展示条数。
enum TodoListItemCount {
    
    /// 小号列表组件的展示条数
    static let smallList = 3
    
    /// 中号列表组件的展示条数
    static let mediumList = 3
    
    /// 大号列表组件的展示条数
    static let largeList = 6
}

// MARK: - 组件提供者基类

/// 待办清单行组件提供者基类。
///
/// 各尺寸列表组件只需声明「类型 + 展示条数」，取数与交互由基类统一提供。
class TodoListRowsPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 最多展示的清单数目
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
        return TodoListRowsContentInteractor(plugin: plugin,
                                             context: context,
                                             maximumItemCount: itemCount)
    }
    
    /// 没有清单时，沿用待办模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No List")
        return configuration
    }
}

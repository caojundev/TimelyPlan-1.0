//
//  WSActionPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 动作组件的展示条数
enum WSActionItemCount {

    /// 小号列表组件的展示条数
    static let smallList = 3

    /// 中号列表组件的展示条数
    static let mediumList = 3

    /// 中号网格组件的展示条数
    static let mediumGrid = 4

    /// 大号列表组件的展示条数
    static let largeList = 6

    /// 大号网格组件的展示条数
    static let largeGrid = 8

    /// 网格组件的列数
    static let gridColumnCount = 2
}

// MARK: - 组件提供者基类

/// 动作组件提供者基类。
///
/// 各尺寸列表 / 网格组件只需声明「类型 + 展示条数 + 内容视图」，取数与配置由基类统一提供。
class WSActionPluginProvider: WSPluginProvider {

    /// 插件类型
    let type: WSPluginType

    /// 最多展示的动作数目
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
        return WSActionContentInteractor(plugin: plugin,
                                         context: context,
                                         maximumItemCount: itemCount)
    }

    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSActionConfigViewController(plugin: plugin)
    }

    /// 未配置动作时提示配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "bolt"
        configuration.title = resGetString("No Actions")
        return configuration
    }
}

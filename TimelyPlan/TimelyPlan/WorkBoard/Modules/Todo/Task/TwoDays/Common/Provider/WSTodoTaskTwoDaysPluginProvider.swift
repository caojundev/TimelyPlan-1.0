//
//  WSTodoTaskTwoDaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 布局

/// 今明两天组件的布局参数
enum WSTodoTaskTwoDaysLayout {

    /// 每列最多展示的任务数目
    static let maximumRowCount = 3
}

// MARK: - 组件提供者基类

/// 待办今明两天组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 每列展示条数」，取数、内容视图与交互由基类统一提供。
class WSTodoTaskTwoDaysPluginProvider: WSPluginProvider {

    /// 插件类型
    let type: WSPluginType

    /// 每列最多展示的任务数目
    let itemCount: Int

    init(type: WSPluginType, itemCount: Int) {
        self.type = type
        self.itemCount = itemCount
    }

    /// 该组件尺寸
    var size: WSPluginSize {
        return type.size
    }

    func makeContentView() -> WSPluginContentView {
        return WSTodoTaskTwoDaysContentView(maximumRowCount: itemCount)
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTodoTaskTwoDaysContentInteractor(plugin: plugin, context: context)
    }

    /// 没有任务时，沿用待办模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No Task")
        return configuration
    }
}

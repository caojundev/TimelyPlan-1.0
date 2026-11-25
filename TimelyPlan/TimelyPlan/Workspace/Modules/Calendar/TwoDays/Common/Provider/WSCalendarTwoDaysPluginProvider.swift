//
//  WSCalendarTwoDaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 布局

/// 今明两天组件的布局参数
enum WSCalendarTwoDaysLayout {

    /// 中尺寸每列最多展示的事项数目。事项行含时间与来源两行，头部占比固定，故只放两行
    static let mediumRowCount = 2

    /// 大尺寸每列最多展示的事项数目
    static let largeRowCount = 6
}

// MARK: - 组件提供者基类

/// 日历今明两天组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 每列展示条数」，取数、内容视图与交互由基类统一提供。
class WSCalendarTwoDaysPluginProvider: WSPluginProvider {

    /// 插件类型
    let type: WSPluginType

    /// 每列最多展示的事项数目
    let itemCount: Int

    init(type: WSPluginType, itemCount: Int) {
        self.type = type
        self.itemCount = itemCount
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarTwoDaysContentView(maximumRowCount: itemCount)
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarTwoDaysContentInteractor(plugin: plugin, context: context)
    }

    /// 没有事项时，沿用日历模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "calendar"
        configuration.title = resGetString("No Events")
        return configuration
    }
}

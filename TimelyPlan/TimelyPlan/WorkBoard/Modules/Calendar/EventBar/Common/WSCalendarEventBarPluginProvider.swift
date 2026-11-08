//
//  WSCalendarEventBarPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历事项条组件提供者基类。
///
/// 各组件只需声明「类型 + 显示范围」，内容视图、交互器与空白状态由基类统一提供，
/// 唯一差异是取数的日期范围。
class WSCalendarEventBarPluginProvider: WSPluginProvider {

    /// 插件类型
    let type: WSPluginType

    /// 显示范围
    let range: WSCalendarEventBarRange

    init(type: WSPluginType, range: WSCalendarEventBarRange) {
        self.type = type
        self.range = range
    }

    func makeContentView() -> WSPluginContentView {
        let view = WSCalendarEventBarView(startDate: range.startDate(), dayCount: range.dayCount)
        view.padding = UIEdgeInsets(value: 8.0)
        return view
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarEventBarContentInteractor(plugin: plugin,
                                                   context: context,
                                                   range: range)
    }

    /// 没有事项时，沿用日历模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "calendar"
        configuration.title = resGetString("No Events")
        return configuration
    }
}

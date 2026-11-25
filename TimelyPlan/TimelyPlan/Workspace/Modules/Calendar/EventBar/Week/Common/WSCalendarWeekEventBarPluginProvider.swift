//
//  WSCalendarWeekEventBarPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历周事项条组件提供者基类。
///
/// 各组件只需声明「类型 + 显示周数」，内容视图、交互器与空白状态由基类统一提供，
/// 唯一差异是取数的日期范围。
class WSCalendarWeekEventBarPluginProvider: WSPluginProvider {

    /// 插件类型
    let type: WSPluginType

    /// 显示周数
    let weekCount: Int

    init(type: WSPluginType, weekCount: Int) {
        self.type = type
        self.weekCount = weekCount
    }

    func makeContentView() -> WSPluginContentView {
        let view = WSCalendarWeekEventBarView(startDate: Date(), weekCount: weekCount)
        view.padding = UIEdgeInsets(value: 8.0)
        return view
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarWeekEventBarContentInteractor(plugin: plugin,
                                                       context: context,
                                                       weekCount: weekCount)
    }

    /// 没有事项时，沿用日历模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "calendar"
        configuration.title = resGetString("No Events")
        return configuration
    }
}

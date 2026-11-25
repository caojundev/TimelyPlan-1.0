//
//  WSCalendarLargeMonthEventBarPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历·大·月事项条（当月）：按当月网格展示 5~6 周的事项条。
class WSCalendarLargeMonthEventBarPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.largeMonthEventBar
    }

    func makeContentView() -> WSPluginContentView {
        let view = WSCalendarMonthEventBarView(monthDate: Date())
        view.padding = UIEdgeInsets(value: 8.0)
        return view
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarMonthEventBarContentInteractor(plugin: plugin, context: context)
    }

    /// 没有事项时，沿用日历模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "calendar"
        configuration.title = resGetString("No Events")
        return configuration
    }
}

//
//  WSTodoTaskSmallNextTrendsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·小·接下来七天。展示从后天起七天的任务负载分布。
class WSTodoTaskSmallNextTrendsPluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .TodoSmartListTask.smallNextTrends
    }

    func makeContentView() -> WSPluginContentView {
        return WSTodoTaskSmallNextTrendsContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTodoTaskNextTrendsContentInteractor(plugin: plugin, context: context)
    }

    /// 没有任务时，沿用待办模块的空白文案
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No Task")
        return configuration
    }
}

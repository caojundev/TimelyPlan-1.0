//
//  WSTodoTaskMediumNextTrendsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·接下来七天。左侧展示七天任务负载，右侧展示接下来要做的任务。
class WSTodoTaskMediumNextTrendsPluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .TodoTask.mediumNextTrends
    }

    func makeContentView() -> WSPluginContentView {
        return WSTodoTaskMediumNextTrendsContentView()
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

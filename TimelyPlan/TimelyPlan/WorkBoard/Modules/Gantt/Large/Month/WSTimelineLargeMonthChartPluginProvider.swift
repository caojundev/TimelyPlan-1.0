//
//  WSTimelineLargeMonthChartPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 时间线·大·按月甘特图。以甘特时间线按月展示事项排期。
final class WSTimelineLargeMonthChartPluginProvider: WSPluginProvider {

    let type: WSPluginType = .timelineLargeMonthChart

    func makeContentView() -> WSPluginContentView {
        return WSTimelineChartContentView(timeScale: GanttTimeScale(scale: .month, date: Date()))
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTimelineChartContentInteractor(plugin: plugin, context: context, scale: .month)
    }
}

//
//  WSTimelineLargeDayChartPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 时间线·大·按天甘特图。以甘特时间线按天展示事项排期。
final class WSTimelineLargeDayChartPluginProvider: WSPluginProvider {

    let type: WSPluginType = .timelineLargeDayChart

    func makeContentView() -> WSPluginContentView {
        return WSTimelineChartContentView(timeScale: GanttTimeScale(scale: .day, date: Date()))
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTimelineChartContentInteractor(plugin: plugin, context: context, scale: .day)
    }
}

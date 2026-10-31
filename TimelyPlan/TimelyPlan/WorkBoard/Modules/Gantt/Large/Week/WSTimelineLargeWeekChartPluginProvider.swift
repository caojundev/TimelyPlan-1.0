//
//  WSTimelineLargeWeekChartPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 时间线·大·按周甘特图。以甘特时间线按周展示事项排期。
final class WSTimelineLargeWeekChartPluginProvider: WSPluginProvider {

    let type: WSPluginType = .timelineLargeWeekChart

    func makeContentView() -> WSPluginContentView {
        return WSTimelineChartContentView(scale: .week)
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTimelineChartContentInteractor(plugin: plugin, context: context, scale: .week)
    }
}

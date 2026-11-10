//
//  WSCalendarLargeTimelinePluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

/// 日历·大·时间线的组件提供者。展示当前整点起 6 个小时。
class WSCalendarLargeTimelinePluginProvider: WSPluginProvider {

    /// 展示的小时数
    private let hourCount = 6

    var type: WSPluginType {
        return .Calendar.largeTimeline
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarLargeTimelineContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarTimelineContentInteractor(plugin: plugin,
                                                   context: context,
                                                   hourCount: hourCount)
    }
}

//
//  WSCalendarMediumTimelinePluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历·中·时间线的组件提供者。展示当前整点起 4 个小时。
class WSCalendarMediumTimelinePluginProvider: WSPluginProvider {

    /// 展示的小时数
    private let hourCount = 4

    var type: WSPluginType {
        return .Calendar.mediumTimeline
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarMediumTimelineContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarTimelineContentInteractor(plugin: plugin,
                                                   context: context,
                                                   hourCount: hourCount)
    }
}

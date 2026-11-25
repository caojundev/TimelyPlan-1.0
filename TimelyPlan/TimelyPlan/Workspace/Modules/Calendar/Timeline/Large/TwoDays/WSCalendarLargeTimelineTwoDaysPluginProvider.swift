//
//  WSCalendarLargeTimelineTwoDaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

/// 日历·大·两天时间线的组件提供者。左侧展示今天，右侧固定展示明天的 09:00 ~ 16:00。
class WSCalendarLargeTimelineTwoDaysPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.largeTimelineTwoDays
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarLargeTimelineTwoDaysContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarLargeTimelineTwoDaysContentInteractor(plugin: plugin, context: context)
    }
}

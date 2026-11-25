//
//  WSCalendarLargeUpcomingPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·大·最近事项的组件提供者。
class WSCalendarLargeUpcomingPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.largeUpcoming
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarLargeUpcomingContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarUpcomingContentInteractor(plugin: plugin, context: context)
    }
}

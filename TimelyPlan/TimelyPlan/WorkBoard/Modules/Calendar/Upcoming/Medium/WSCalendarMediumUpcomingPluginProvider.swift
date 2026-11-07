//
//  WSCalendarMediumUpcomingPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·中·最近事项的组件提供者。
class WSCalendarMediumUpcomingPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.mediumUpcoming
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarMediumUpcomingContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarUpcomingContentInteractor(plugin: plugin, context: context)
    }
}

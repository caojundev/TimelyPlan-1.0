//
//  WSCalendarSmallUpcomingPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·最近事项的组件提供者。
class WSCalendarSmallUpcomingPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.smallUpcoming
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarSmallUpcomingContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarUpcomingContentInteractor(plugin: plugin, context: context)
    }
}

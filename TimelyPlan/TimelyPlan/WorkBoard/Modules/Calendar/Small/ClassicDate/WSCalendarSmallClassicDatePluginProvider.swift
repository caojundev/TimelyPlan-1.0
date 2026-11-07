//
//  WSCalendarSmallClassicDatePluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·经典日期的组件提供者。
class WSCalendarSmallClassicDatePluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.smallClassicDate
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarSmallClassicDateContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarTodayDateContentInteractor(plugin: plugin, context: context)
    }
}

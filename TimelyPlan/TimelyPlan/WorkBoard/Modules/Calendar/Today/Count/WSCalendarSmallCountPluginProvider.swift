//
//  WSCalendarSmallCountPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·今日事项数目的组件提供者。
class WSCalendarSmallCountPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.smallCount
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarSmallCountContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarTodayCountContentInteractor(plugin: plugin, context: context)
    }
}

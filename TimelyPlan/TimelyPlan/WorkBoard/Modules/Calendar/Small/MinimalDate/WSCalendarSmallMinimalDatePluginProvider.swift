//
//  WSCalendarSmallMinimalDatePluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·极简日期的组件提供者。
class WSCalendarSmallMinimalDatePluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.smallMinimalDate
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarSmallMinimalDateContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarTodayDateContentInteractor(plugin: plugin, context: context)
    }
}

//
//  WSCalendarSmallMonthPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·小·月历的组件提供者。
class WSCalendarSmallMonthPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.smallMonth
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarSmallMonthContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarMonthContentInteractor(plugin: plugin, context: context)
    }
}

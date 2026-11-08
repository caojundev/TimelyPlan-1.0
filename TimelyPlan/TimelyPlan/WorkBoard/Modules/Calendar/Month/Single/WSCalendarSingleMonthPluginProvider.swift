//
//  WSCalendarSingleMonthPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·单月历（小尺寸）的组件提供者。
class WSCalendarSingleMonthPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.smallMonth
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarSingleMonthContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarMonthContentInteractor(plugin: plugin, context: context)
    }
}

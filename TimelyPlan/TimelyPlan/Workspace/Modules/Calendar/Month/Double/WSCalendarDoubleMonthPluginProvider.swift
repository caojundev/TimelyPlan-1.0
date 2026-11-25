//
//  WSCalendarDoubleMonthPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 日历·双月历（中尺寸）的组件提供者。
class WSCalendarDoubleMonthPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.mediumMonth
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarDoubleMonthContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarDoubleMonthContentInteractor(plugin: plugin, context: context)
    }
}

// MARK: - 内容交互器

/// 日历·双月历的内容交互器：同时取本月与下月的数据。
class WSCalendarDoubleMonthContentInteractor: WSCalendarMonthContentInteractor {

    override var monthCount: Int {
        return 2
    }
}

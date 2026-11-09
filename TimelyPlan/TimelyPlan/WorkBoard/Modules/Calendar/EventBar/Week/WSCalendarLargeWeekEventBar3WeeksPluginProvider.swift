//
//  WSCalendarLargeWeekEventBar3WeeksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历·大·周事项条（3 周）：展示本周起 3 周的事项条。
class WSCalendarLargeWeekEventBar3WeeksPluginProvider: WSCalendarWeekEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.largeWeekEventBar3Weeks, weekCount: 3)
    }
}

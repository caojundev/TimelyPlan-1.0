//
//  WSCalendarLargeWeekEventBar4WeeksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历·大·周事项条（4 周）：展示本周起 4 周的事项条。
class WSCalendarLargeWeekEventBar4WeeksPluginProvider: WSCalendarWeekEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.largeWeekEventBar4Weeks, weekCount: 4)
    }
}

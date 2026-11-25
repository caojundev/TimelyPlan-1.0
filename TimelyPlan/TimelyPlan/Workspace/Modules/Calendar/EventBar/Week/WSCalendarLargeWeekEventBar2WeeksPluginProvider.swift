//
//  WSCalendarLargeWeekEventBar2WeeksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历·大·周事项条（2 周）：展示本周起 2 周的事项条。
class WSCalendarLargeWeekEventBar2WeeksPluginProvider: WSCalendarWeekEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.largeWeekEventBar2Weeks, weekCount: 2)
    }
}

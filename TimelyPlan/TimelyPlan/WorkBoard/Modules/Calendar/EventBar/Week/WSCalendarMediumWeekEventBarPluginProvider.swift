//
//  WSCalendarMediumWeekEventBarPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历·中·周事项条（本周）：展示本周的事项条。
class WSCalendarMediumWeekEventBarPluginProvider: WSCalendarWeekEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.mediumWeekEventBar, weekCount: 1)
    }
}

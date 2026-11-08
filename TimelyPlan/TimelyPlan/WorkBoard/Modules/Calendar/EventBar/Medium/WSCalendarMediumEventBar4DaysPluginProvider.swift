//
//  WSCalendarMediumEventBar4DaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·中·事项条（4 天）：展示今天起 4 天的事项。
class WSCalendarMediumEventBar4DaysPluginProvider: WSCalendarEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.mediumEventBar4Days, range: .days(4))
    }
}

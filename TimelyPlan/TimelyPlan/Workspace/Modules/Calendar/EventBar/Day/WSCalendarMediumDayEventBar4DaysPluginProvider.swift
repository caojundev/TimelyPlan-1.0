//
//  WSCalendarMediumDayEventBar4DaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·中·事项条（4 天）：展示今天起 4 天的事项。
class WSCalendarMediumDayEventBar4DaysPluginProvider: WSCalendarDayEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.mediumEventBar4Days, dayCount: 4)
    }
}

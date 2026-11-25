//
//  WSCalendarMediumDayEventBar2DaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·中·事项条（2 天）：展示今天起 2 天的事项。
class WSCalendarMediumDayEventBar2DaysPluginProvider: WSCalendarDayEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.mediumEventBar2Days, dayCount: 2)
    }
}

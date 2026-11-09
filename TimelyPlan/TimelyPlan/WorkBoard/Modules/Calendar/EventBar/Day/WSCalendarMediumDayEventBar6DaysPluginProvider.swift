//
//  WSCalendarMediumDayEventBar6DaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历·中·事项条（6 天）：展示今天起 6 天的事项。
class WSCalendarMediumDayEventBar6DaysPluginProvider: WSCalendarDayEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.mediumEventBar6Days, dayCount: 6)
    }
}

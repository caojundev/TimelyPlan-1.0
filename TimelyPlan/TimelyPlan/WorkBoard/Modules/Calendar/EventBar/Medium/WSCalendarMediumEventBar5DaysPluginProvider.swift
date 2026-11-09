//
//  WSCalendarMediumEventBar5DaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·中·事项条（5 天）：展示今天起 5 天的事项。
class WSCalendarMediumEventBar5DaysPluginProvider: WSCalendarEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.mediumEventBar5Days, dayCount: 5)
    }
}

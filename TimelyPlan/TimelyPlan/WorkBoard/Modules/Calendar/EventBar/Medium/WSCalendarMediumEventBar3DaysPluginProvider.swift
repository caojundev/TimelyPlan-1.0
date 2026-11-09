//
//  WSCalendarMediumEventBar3DaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·中·事项条（3 天）：展示今天起 3 天的事项。
class WSCalendarMediumEventBar3DaysPluginProvider: WSCalendarEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.mediumEventBar3Days, dayCount: 3)
    }
}

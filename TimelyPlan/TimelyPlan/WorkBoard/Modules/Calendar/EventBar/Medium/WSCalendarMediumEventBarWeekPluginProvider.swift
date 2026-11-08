//
//  WSCalendarMediumEventBarWeekPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·中·事项条（本周）：展示今天所在那一周的事项。
class WSCalendarMediumEventBarWeekPluginProvider: WSCalendarEventBarPluginProvider {

    init() {
        super.init(type: .Calendar.mediumEventBarWeek, range: .week)
    }
}

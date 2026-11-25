//
//  WSCalendarMediumTwoDaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 日历·中·今明两天。按今天、明天两列展示事项。
class WSCalendarMediumTwoDaysPluginProvider: WSCalendarTwoDaysPluginProvider {

    init() {
        super.init(type: .Calendar.mediumTwoDays,
                   itemCount: WSCalendarTwoDaysLayout.mediumRowCount)
    }
}

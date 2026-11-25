//
//  WSCalendarLargeTwoDaysPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 日历·大·今明两天。按今天、明天两列展示事项。
class WSCalendarLargeTwoDaysPluginProvider: WSCalendarTwoDaysPluginProvider {

    init() {
        super.init(type: .Calendar.largeTwoDays,
                   itemCount: WSCalendarTwoDaysLayout.largeRowCount)
    }
}

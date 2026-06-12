//
//  CalendarMode.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/30.
//

import Foundation

enum CalendarMode: Int, TPMenuRepresentable {
    case day
    case week
    case month
    
    var title: String {
        switch self {
        case .day:
            return resGetString("Day")
        case .week:
            return resGetString("Week")
        case .month:
            return resGetString("Month")
        }
    }

    var iconName: String? {
        var name: String
        switch self {
        case .day:
            name = "calendar_mode_day"
        case .week:
            name = "calendar_mode_week"
        case .month:
            name = "calendar_mode_month"
        }
        
        return resGetShotName(name, size: .mini)
    }
}

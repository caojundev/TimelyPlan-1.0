//
//  CalendarMode.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/30.
//

import Foundation

enum CalendarMode: Int, TPMenuRepresentable {
    case list
    case day
    case week
    case month
    case quarter
    case year
    
    var title: String {
        switch self {
        case .list:
            return resGetString("List")
        case .day:
            return resGetString("Day")
        case .week:
            return resGetString("Week")
        case .month:
            return resGetString("Month")
        case .quarter:
            return resGetString("Quarter")
        case .year:
            return resGetString("Year")
        }
    }

    var iconName: String? {
        var name: String
        switch self {
        case .list:
            name = "calendar_list"
        case .day:
            name = "calendar_day"
        case .week:
            name = "calendar_week"
        case .month:
            name = "calendar_month"
        case .quarter:
            name = "calendar_quarter"
        case .year:
            name = "calendar_year"
        }
        
        return resGetShotName(name, size: .mini)
    }
}

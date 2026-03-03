//
//  HabitTimeOption.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/2.
//

import Foundation

/// 代表习惯发生的时间段
enum HabitTimeOption: Int, TPMenuRepresentable {
    case anytime
    case morning
    case afternoon
    case evening

    static func titles() -> [String] {
        return ["Anytime", "Morning", "Afternoon", "Evening"]
    }

    var iconName: String? {
        switch self {
        case .anytime: return "habit_time_anytime_24"
        case .morning: return "habit_time_morning_24"
        case .afternoon: return "habit_time_afternoon_24"
        case .evening: return "habit_time_evening_24"
        }
    }
}

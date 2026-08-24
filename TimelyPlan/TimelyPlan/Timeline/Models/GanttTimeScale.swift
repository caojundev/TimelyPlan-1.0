//
//  GanttTimeScale.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation

struct GanttTimeScale {
    
    enum Scale: Int, Codable, TPMenuRepresentable {
        case day
        case week
        case month
        
        var pixelsPerUnit: CGFloat {
            switch self {
            case .day: return 60
            case .week: return 100
            case .month: return 150
            }
        }
        
        static func titles() -> [String] {
            return ["By Day", "By Week", "By Month"]
        }
        
        var iconName: String? {
            switch self {
            case .day:
                return "ganttTimeScale_day_24"
            case .week:
                return "ganttTimeScale_week_24"
            case .month:
                return "ganttTimeScale_month_24"
            }
        }
    }
    
    var scale: Scale = .day
    let startDate: Date
    let endDate: Date
}

//
//  GanttTimeScale.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation

struct GanttTimeScale: Equatable {
    
    enum Scale: Int, Codable, TPMenuRepresentable {
        case day
        case week
        case month
        
        var pixelsPerUnit: CGFloat {
            switch self {
            case .day: return 100
            case .week: return 160
            case .month: return 240
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
    
    let scale: Scale
    let startDate: Date
    let endDate: Date
    
    init(scale: Scale, date: Date, firstWeekday: Weekday = .sunday) {
        self.scale = scale
        var startDate = date.startOfYear()
        var endDate = date.endOfYear()
        if scale == .week {
            startDate = Self.weekRange(for: startDate, firstWeekday: firstWeekday).start
            endDate = Self.weekRange(for: endDate, firstWeekday: firstWeekday).end
        }
        
        self.startDate = startDate
        self.endDate = endDate
    }
    
    /// 根据 firstWeekday 计算给定日期所在周的实际开始/结束日期
    private static func weekRange(for date: Date, firstWeekday: Weekday = .sunday) -> (start: Date, end: Date) {
        let calendar = Calendar.current

        // 该日期距本周 firstWeekday 的天数差（0 ~ 6）
        let weekday = calendar.component(.weekday, from: date)
        let daysFromWeekStart = (weekday - firstWeekday.rawValue + 7) % 7

        let weekStart = calendar.date(byAdding: .day, value: -daysFromWeekStart, to: date) ?? date
        var weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        weekEnd = weekEnd.endOfDay()
        
        return (weekStart, weekEnd)
    }

}

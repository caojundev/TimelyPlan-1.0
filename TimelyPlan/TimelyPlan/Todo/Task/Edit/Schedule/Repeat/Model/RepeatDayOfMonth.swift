//
//  RepeatDayOfMonth.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/18.
//

import Foundation

/// 月重复模式
enum RepeatMonthlyMode: Int, TPMenuRepresentable {
    case onDays
    case onWeek
    
    static func titles() -> [String] {
        return ["On Days", "On Week"]
    }
}

/// 月重复 WeekNumber
enum RepeatWeekNumber: Int, TPMenuRepresentable {
    case last = -1
    case first = 1
    case second
    case third
    case fourth
    case fifth
    
    var title: String {
        let title: String
        switch self {
        case .first:
            title = "First"
        case .second:
            title = "Second"
        case .third:
            title = "Third"
        case .fourth:
            title = "Fourth"
        case .fifth:
            title = "Fifth"
        case .last:
            title = "Last"
        }
        
        return resGetString(title)
    }
}

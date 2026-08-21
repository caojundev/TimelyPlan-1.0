//
//  TimelineAllDayEventsDisplayOption.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/21.
//

import Foundation

// MARK: - 全天事项显示配置

enum TimelineAllDayEventsDisplayOption: Int, Codable, TPMenuRepresentable {
    case show1 = 1
    case show2 = 2
    case show3 = 3
    case show5 = 5
    case showAll = -1  // 显示全部

    var title: String {
        switch self {
        case .show1:
            return "1"
        case .show2:
            return "2"
        case .show3:
            return "3"
        case .show5:
            return "5"
        case .showAll:
            return resGetString("Show All")
        }
    }
    
    var maxVisibleCount: Int? {
        switch self {
        case .showAll:
            return nil  // nil 表示不限制
        default:
            return self.rawValue
        }
    }
    
    static var defaultValue: TimelineAllDayEventsDisplayOption {
        return .show3
    }
}

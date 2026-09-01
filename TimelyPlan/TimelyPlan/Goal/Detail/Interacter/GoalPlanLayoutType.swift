//
//  GoalPlanLayoutType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation

/// 布局类型
enum GoalPlanLayoutType: Int, Codable, TPMenuRepresentable {
    
    case list
    case board
    
    static func titles() -> [String] {
        return ["List", "Board"]
    }

    var iconName: String? {
        switch self {
        case .list:
            return "todo_list_layout_list_96"
        case .board:
            return "todo_list_layout_board_96"
        }
    }
    
    var miniIconName: String {
        switch self {
        case .list:
            return "todo_list_24"
        case .board:
            return "todo_board_24"
        }
    }
}

//
//  TodoListLayoutType.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/25.
//

import Foundation

/// 列表布局类型
enum TodoListLayoutType: Int, Codable, TPMenuRepresentable {
    
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
            return "todo_list_board_24"
        }
    }
}

//
//  TaskPriority.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/26.
//

import Foundation
import UIKit

enum TodoTaskPriority: Int, Codable, TPMenuRepresentable {
    
    case none   = 0 /// 无
    case low    = 1 /// 低
    case medium = 2 /// 中
    case high   = 3 /// 高
    
    var identifier: String {
        return String(describing: TodoTaskPriority.self) + "\(self.rawValue)"
    }
    
    static var priorities: [TodoTaskPriority] {
        return TodoTaskPriority.allCases.reversed()
    }
    
    static func titles() -> [String] {
        return ["No Priority",
                "Low Priority",
                "Medium Priority",
                "High Priority"]
    }
    
    var color: UIColor {
        switch self {
        case .none:
            return Color(light: 0x646566, dark: 0xabacad)
        case .low:
            return .primary
        case .medium:
            return .warning6
        case .high:
            return .danger6
        }
    }
    
    /// 图标名称
    var iconName: String? {
        if self == .none {
            return "todo_task_priority_24"
        }
        
        return "todo_task_priority_fill_24"
    }

    /// 图标颜色
    var iconColor: UIColor {
        return titleColor
    }
    
    /// 标题颜色
    var titleColor: UIColor {
        return color
    }
    
    /// 样式
    var actionStyle: TPMenuActionStyle {
        return .custom
    }
}

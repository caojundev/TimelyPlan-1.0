//
//  GoalTaskGroupType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/7.
//

import Foundation

/// 目标任务分组类型
enum GoalTaskGroupType: String, Codable, TPMenuRepresentable {
    /// 完成状态（按是否勾选完成分组）
    case `default`
    /// 目标达成状态（按数值目标是否达成及执行进度分组）
    case targetStatus
    /// 权重（按权重高/中/低分组）
    case weight
    /// 无分组
    case none
    
    /// 分组菜单标题
    static func titles() -> [String] {
        return ["Default",
                "Target Status",
                "Weight",
                "None Group"]
    }
    
    var iconName: String? {
        switch self {
        case .default:
            return "todo_group_type_default_24"
        case .targetStatus:
            /// 复用完成类图标表示目标达成状态
            return "todo_group_type_completionDate_24"
        case .weight:
            /// 复用优先级图标表示权重分组
            return "todo_group_type_priority_24"
        case .none:
            return "todo_group_type_none_24"
        }
    }
    
    var handleBeforeDismiss: Bool {
        return true
    }
}

//
//  FocusStatsTypes.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/3.
//

import Foundation

enum FocusStatsMode: Int {
    case overall
    case specificTimer
    case specificTask
    case specificTimerAndTask
}

/// 专注详情分组类型
enum FocusStatsDetailGroupType: String, TPMenuRepresentable {
    case task  /// 按任务
    case timer /// 按计时器
    
    static func titles() -> [String] {
        return ["By Task", "By Timer"]
    }
    
    var iconName: String? {
        switch self {
        case .task:
            return "focus_stats_group_task_24"
        case .timer:
            return "focus_stats_group_timer_24"
        }
    }
}

//
//  HabitTaskFilterType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/10.
//

import Foundation

enum HabitTaskFilterType: Int, TPMenuRepresentable {
    case all        /// 所有
    case todo       /// 待完成
    case completed  /// 完成
    case skipped    /// 跳过
    case failed     /// 失败
    
    var title: String {
        switch self {
        case .all:
            return resGetString("All")
        case .todo:
            return resGetString("To-dos")
        case .completed:
            return resGetString("Completed")
        case .skipped:
            return resGetString("Skipped")
        case .failed:
            return resGetString("Failed")
        }
    }
}

//
//  FocusStatsTypes.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/3.
//

import Foundation

/// 专注详情分组类型
enum FocusStatsDetailGroupType: String, TPMenuRepresentable {
    case task  /// 按任务
    case timer /// 按计时器
    
    static func titles() -> [String] {
        return ["By Task", "By Timer"]
    }
}

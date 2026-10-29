//
//  WSGoalTaskSelectedTasksConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation

// MARK: - 配置

/// 目标任务多选组件的配置
struct WSGoalTaskSelectedTasksConfiguration: Codable {
    
    /// 用户选择的目标任务标识，按选择顺序排列
    var taskIdentifiers: [String] = []
}

//
//  WSGoalPlanSelectedPlansConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation

// MARK: - 配置

/// 目标计划多选组件的配置
struct WSGoalPlanSelectedPlansConfiguration: Codable {
    
    /// 用户选择的目标计划标识，按选择顺序排列
    var planIdentifiers: [String] = []
}

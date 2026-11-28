//
//  WSQuadrantTaskConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation

// MARK: - 配置

/// 四象限任务组件的配置
struct WSQuadrantTaskConfiguration: Codable {
    
    /// 用户选择的象限。为 nil 表示尚未配置，组件展示空白占位
    var quadrant: Quadrant?
}

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
    
    /// 用户选择的象限
    var quadrant: Quadrant?
    
    /// 实际展示的象限。未选择时取象限布局中的第一个
    var targetQuadrant: Quadrant {
        if let quadrant = quadrant {
            return quadrant
        }
        
        return QuadrantSetting.shared.layout.getQuadrants().first ?? .urgentImportant
    }
}

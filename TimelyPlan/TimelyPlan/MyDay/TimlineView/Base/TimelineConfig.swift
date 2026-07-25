//
//  TimelineConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation

// MARK: - 配置

struct TimelineConfig {
    // MARK: 布局常量
    static let leftTimeWidth: CGFloat = 36
    static let margin: CGFloat = 16
    static let centerNodeWidth: CGFloat = 40
    static let rightCircleSize: CGFloat = 20
    
    // MARK: Cell 高度
    static let pointCellHeight: CGFloat = 80
    static let shortCellHeight: CGFloat = 120
    static let longCellHeight: CGFloat = 160
    
    // MARK: 连接线配置
    static let solidLineWidth: CGFloat = 2
    static let dashedLineWidth: CGFloat = 2
    static let overlappingLineWidth: CGFloat = 40
    
    static let dashedPattern: [NSNumber] = [4, 4]
    
    /// 实线连接线最小高度
    static let solidConnectionMinHeight: CGFloat = 20.0
    /// 实线连接线最大高度
    static let solidConnectionMaxHeight: CGFloat = 40.0
    
    /// 虚线连接线高度
    static let dashedConnectionHeight: CGFloat = 80.0
    
    /// 重叠样式连接线默认高度
    static let overlappingConnectionHeight: CGFloat = 30.0
    
    /// 时间间隔阈值（分钟）：大于等于此值为虚线，小于此值为实线
    static let dashedThresholdMinutes: TimeInterval = 30 * 60
    
    // MARK: 图标配置
    static let iconSize: CGFloat = 24
    
    // MARK: 字体配置
    static let timeFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    static let timeColor = UIColor.lightGray
}


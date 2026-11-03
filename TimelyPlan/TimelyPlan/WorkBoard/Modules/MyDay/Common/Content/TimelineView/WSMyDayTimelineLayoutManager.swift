//
//  WSMyDayTimelineLayoutManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 布局管理

/// 插件时间线的布局尺寸。
///
/// 组件高度有限，事项行与连接线高度都在 `TimelineLayoutManager` 的基础上缩小，
/// 连接样式与顺序仍由 `TimelineTimedEventConverter` 决定。
struct WSMyDayTimelineLayoutManager {
    
    /// 节点与连接线的底色
    ///
    /// 插件内的节点与连接线固定使用深色，避免浅色模式下取到未来日期的浅灰底色
    static let trackColor = Color(0x262626)
    
    /// 事项行高度
    static func cellHeight(for item: TimelineItem) -> CGFloat {
        switch item.type {
        case .point:
            return 62.0
        case .short:
            return 78.0
        case .long:
            return 96.0
        }
    }
    
    /// 连接线行高度：按原高度等比缩小，并保证最小高度
    static func connectionHeight(for item: TimelineConnectionItem) -> CGFloat {
        return max(item.height * 0.5, 12.0)
    }
}

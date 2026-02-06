//
//  TPPopoverPosition.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/9.
//

import Foundation

/// 弹窗位置
enum TPPopoverPosition: Int, CaseIterable {
    case center
    case topLeft
    case topCenter
    case topRight
    case bottomLeft
    case bottomCenter
    case bottomRight
    case centerLeft
    case centerRight
    
    /// 顶部位置
    static var topPopoverPositions: [TPPopoverPosition] {
        return [.topLeft, .topCenter, .topRight]
    }
    
    /// 底部位置
    static var bottomPopoverPositions: [TPPopoverPosition] {
        return [.bottomLeft, .bottomCenter, .bottomRight]
    }

}

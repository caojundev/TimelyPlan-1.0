//
//  CGSize+Size.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/27.
//

import Foundation

/// 尺寸
extension CGSize {
    
    /// 迷你（24pt）
    static let mini = size(6)
    
    /// 较小（28pt）
    static let small = size(7)
    
    /// 中等（32px）
    static let `default` = size(8)
    
    /// 较大（36px）
    static let large = size(9)
    
    static func size(_ n: Int) -> CGSize {
        let w = 4 * n
        return CGSize(width: w, height: w)
    }
    
    /// 弹窗尺寸
    struct Popover {
        static let contentWidth = 420.0
        static let mini = CGSize(width: contentWidth, height: 280.0)
        static let small = CGSize(width: contentWidth, height: 320.0)
        static let medium = CGSize(width: contentWidth, height: 480.0)
        static let large = CGSize(width: contentWidth, height: 640.0)
        static let extraLarge = CGSize(width: contentWidth, height: 740.0)
    }
}

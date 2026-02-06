//
//  Layout.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/23.
//

import Foundation

/// 边框
struct Border {
    
    /// 无边框
    static let none = 0.0
    
    /// 常规1px
    static let border1 = 1.0
    
    /// 较粗1px
    static let border2 = 2.0
    
    /// 粗2px
    static let border3 = 3.0
}

struct FontSize {
    
    /// 辅助次要文案
    static let body1 = 12.0
    
    /// 正文-常规-小
    static let body2 = 13.0
    
    /// 正文-常规
    static let body3 = 14.0
}

struct CornerRadius {
    
    /// 直角
    static let none = 0.0
    
    /// 常规
    static let small = 2.0
    
    /// 中等
    static let medium = 4.0
    
    /// 大
    static let large = 8.0

    /// 中等大
    static let mediumLarge = 8.0
    
    /// 超大
    static let extraLarge = 16.0
    
    /// 全圆角
    static let circle = CGFloat.greatestFiniteMagnitude
}

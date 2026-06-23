//
//  HabitConstant.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/15.
//

import Foundation
import UIKit

/// 习惯相关常量配置
struct HabitConstant {
    
    // MARK: - 布局相关

    /// 习惯内容最大宽度
    static let taskListContentMaxWidth: Double = 560.0
    
    /// 任务编辑输入框圆角
    static let taskEditInputFieldCornerRadius: CGFloat = .greatestFiniteMagnitude
    
    // MARK: - 颜色相关
    
    /// 默认习惯任务颜色
    static let taskDefaultColor = taskColors[0]
    
    static let taskColors = [
        Color(0xFD2504), Color(0xE84F01), Color(0xFF9300),
        Color(0xFCB100), Color(0x306B16), Color(0x26B450),
        Color(0x09AFFF), Color(0x8C36FF), Color(0xBA1910),
        Color(0x00786C), Color(0x0096A7), Color(0x0087D3),
        Color(0x2E3BA3), Color(0x301A94), Color(0x7E22A3),
        Color(0x00CF85), Color(0x999DA8)
    ]

    // MARK: - 默认数值
    
    /// 默认目标数值
    static let goalDefaultTargetAmount: Int64 = 1
    
    /// 默认记录数值
    static let recordDefaultAmount: Int64 = 1
    
    // MARK: - 评分相关
    
    /// 默认完成评分
    static let defaultCompletedScore: Int = 100
    
    /// 默认跳过评分
    static let defaultSkippedScore: Int = 60
    
    /// 默认失败评分
    static let defaultFailedScore: Int = 20
    
    // 私有初始化方法，防止实例化
    private init() {}
}

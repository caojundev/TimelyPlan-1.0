//
//  GoalConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

struct GoalConfig {
    
    /// 目标计划列表内容最大宽度
    static let goalPlanListContentMaxWidth = 560.0
    
    /// 默认目标计划颜色
    static let goalPlanDefaultColor = Color(0xE84F01)
    
    /// 目标计划可选颜色数值
    static let goalPlanColors = [
        Color(0xFD2504), Color(0xE84F01), Color(0xFF9300),
        Color(0xFCB100), Color(0x306B16), Color(0x26B450),
        Color(0x09AFFF), Color(0x8C36FF), Color(0xBA1910),
        Color(0x00786C), Color(0x0096A7), Color(0x0087D3),
        Color(0x2E3BA3), Color(0x301A94), Color(0x7E22A3),
        Color(0x00CF85), Color(0x999DA8)
    ]
    
    /// 标签颜色数组
    static let taskColors: [UIColor] = [.blue(5),
                                        .red(5),
                                        .orange(5),
                                        .green(5),
                                        .purple(5),
                                        .pinkPurple(5),
                                        .cyan(5),
                                        .gray(5)]
    
    
}

//
//  GanttTimelineConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/25.
//

import Foundation
import UIKit

struct GanttTimelineConfig {
    static let insetBottom = 100.0
    
    static let headerHeight = 80.0
    
    static let headerBackgroundColor = UIColor.systemBackground
    
    static let headerSeparatorColor = Color(0x888888, 0.2)
    
    /// 左侧任务列表视图默认宽度
    static let taskListWidth = 180.0
    
    /// 任务列表视图背景色
    static let taskListBackgroundColor = UIColor.systemBackground
    
    /// 任务列表奇数行背景色
    static let taskListOddRowColor = Color(light: 0xF8F8F8, dark: 0x1C1C1E)
    
    /// 任务列表偶数行背景色
    static let taskListEvenRowColor = UIColor.systemBackground
    
    /// 任务列表行分隔线颜色
    static let taskListSeparatorColor = Color(0x888888, 0.2)
    
}

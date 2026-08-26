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
    static let taskListOddRowColor = Color(light: 0xFafafa, dark: 0x0C0C0E)
    
    /// 任务列表偶数行背景色
    static let taskListEvenRowColor = UIColor.systemBackground
    
    /// 任务列表行分隔线颜色
    static let taskListSeparatorColor = Color(0x888888, 0.2)
    
    static let edgeIndicatorBackgroundColor = Color(light: 0xeaeaea, dark: 0x1C1C1C)
    static let edgeIndicatorImageColor = Color(light: 0x3C3C3C, dark: 0xDEDEDE)
}

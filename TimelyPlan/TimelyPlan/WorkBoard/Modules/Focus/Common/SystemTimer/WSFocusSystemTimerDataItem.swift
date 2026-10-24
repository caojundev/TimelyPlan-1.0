//
//  WSFocusSystemTimerDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation

// MARK: - 数据条目

/// 专注·默认计时器的组件数据。小尺寸与中尺寸共用。
///
/// 内容视图只依赖该数据渲染，不直接访问专注数据仓库。
class WSFocusSystemTimerDataItem: NSObject, WSPluginDataItem {
    
    /// 默认番茄钟
    let pomodoroTimer: FocusSystemTimer
    
    /// 默认倒计时
    let countdownTimer: FocusSystemTimer
    
    /// 默认正计时
    let stopwatchTimer: FocusSystemTimer
    
    init(pomodoroTimer: FocusSystemTimer,
         countdownTimer: FocusSystemTimer,
         stopwatchTimer: FocusSystemTimer) {
        self.pomodoroTimer = pomodoroTimer
        self.countdownTimer = countdownTimer
        self.stopwatchTimer = stopwatchTimer
        super.init()
    }
}

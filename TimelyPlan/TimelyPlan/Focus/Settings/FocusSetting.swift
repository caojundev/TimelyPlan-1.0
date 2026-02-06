//
//  FocusSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/9.
//

import Foundation
import UIKit

struct FocusSetting: Codable {
    
    static let keyName = "FocusSetting"
    
    static let defaultAddTimerOnTop = false
    static let defaultMinimumRecordDuration = 5 * SECONDS_PER_MINUTE
    static let minimumRecordMinuteRange = 1...60
    static let defaultAdjustStepDuration = 1 * SECONDS_PER_MINUTE
    static let adjustStepMinuteRange = 1...10
    static let defaultPomodoroAutoStartFocus = true
    static let defaultPomodoroAutoStartBreak = true
    static let defaultSteppedAutoStartNext = true
    static let defaultStopwatchDuration = 3 * SECONDS_PER_HOUR
    static let minimumStopwatchDuration = 1 * SECONDS_PER_MINUTE
    static let defaultIsFloatingTimerNextButtonHidden = true
    static let flipClockAutoHideHour: Bool = true
    
    static let didChangeFloatingTimerNextButtonHiddenNotification = Notification.Name(rawValue: "isFloatingTimerNextButtonHidden")
    
    /// 添加计时器到顶部
    var addTimerOnTop: Bool? = Self.defaultAddTimerOnTop
    
    /// 最小有效记录时长
    var minimumRecordDuration: Duration? = Self.defaultMinimumRecordDuration
    
    /// 单次微调时长
    var adjustStepDuration: Duration? = Self.defaultAdjustStepDuration
    
    /// 正计时最大时长
    var stopwatchDuration: Duration? = Self.defaultStopwatchDuration
    
    /// 番茄钟是否自动开始专注
    var pomodoroAutoStartFocus: Bool? = Self.defaultPomodoroAutoStartFocus
    
    /// 番茄钟是否自动开始休息
    var pomodoroAutoStartBreak: Bool? = Self.defaultPomodoroAutoStartBreak
    
    /// 步骤计时器是否自动开始下一步
    var steppedAutoStartNext: Bool? = Self.defaultSteppedAutoStartNext
    
    /// 浮窗计时器是否显示下一步按钮
    var isFloatingTimerNextButtonHidden: Bool? = Self.defaultIsFloatingTimerNextButtonHidden
    
    /// 翻页时钟自动隐藏小时位
    var flipClockAutoHideHour: Bool? = Self.flipClockAutoHideHour
    
    // MARK: - Getters
    func getAddTimerOnTop() -> Bool {
        return addTimerOnTop ?? Self.defaultAddTimerOnTop
    }
    
    func getPomodoroAutoStartFocus() -> Bool {
        return pomodoroAutoStartFocus ?? Self.defaultPomodoroAutoStartFocus
    }
    
    func getPomodoroAutoStartBreak() -> Bool {
        return pomodoroAutoStartBreak ?? Self.defaultPomodoroAutoStartBreak
    }
    
    func getSteppedAutoStartNext() -> Bool {
        return steppedAutoStartNext ?? Self.defaultSteppedAutoStartNext
    }
    
    func getIsFloatingTimerNextButtonHidden() -> Bool {
        return isFloatingTimerNextButtonHidden ?? Self.defaultIsFloatingTimerNextButtonHidden
    }
    
    func getMinimumRecordDuration() -> Duration {
        #warning("修改数据")
        return 10
        
        guard var minimumRecordDuration = minimumRecordDuration else {
            return Self.defaultMinimumRecordDuration
        }

        clampValue(&minimumRecordDuration,
                   Self.minimumRecordMinuteRange.lowerBound * SECONDS_PER_MINUTE,
                   Self.minimumRecordMinuteRange.upperBound * SECONDS_PER_MINUTE)
        return minimumRecordDuration
    }

    func getAdjustStepDuration() -> Duration {
        guard var adjustStepDuration = adjustStepDuration else {
            return Self.defaultAdjustStepDuration
        }

        clampValue(&adjustStepDuration,
                   Self.adjustStepMinuteRange.lowerBound * SECONDS_PER_MINUTE,
                   Self.adjustStepMinuteRange.upperBound * SECONDS_PER_MINUTE)
        return adjustStepDuration
    }
    
    func getStopwatchDuration() -> Duration {
        guard var stopwatchDuration = stopwatchDuration else {
            return Self.defaultStopwatchDuration
        }
        
        if stopwatchDuration < Self.minimumStopwatchDuration {
            stopwatchDuration = Self.minimumStopwatchDuration
        }
        
        return stopwatchDuration
    }

    func getFlipClockAutoHideHour() -> Bool {
        return flipClockAutoHideHour ?? FocusSetting.flipClockAutoHideHour
    }
}

//
//  FocusSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/9.
//

import Foundation
import UIKit

class FocusSetting {
    static let defaultMinimumRecordDuration = 5 * SECONDS_PER_MINUTE
    static let defaultAdjustStepDuration = 1 * SECONDS_PER_MINUTE
    static let defaultStopwatchMaxDuration = 3 * SECONDS_PER_HOUR
    static let minimumStopwatchDuration = 1 * SECONDS_PER_MINUTE
    static let minimumRecordMinuteRange = 1...60
    static let adjustStepMinuteRange = 1...10
    
    static let didChangeFloatingTimerNextButtonHiddenNotification = Notification.Name(rawValue: "isFloatingTimerNextButtonHidden")

    enum Key: String, SettingKeyRepresentable {
        case firstWeekday
        case addTimerOnTop
        case minimumRecordDuration
        case adjustStepDuration
        case stopwatchMaxDuration
        case pomodoroAutoStartFocus
        case pomodoroAutoStartBreak
        case steppedAutoStartNext
        case isFloatingTimerNextButtonHidden
        case flipClockAutoHideHour
        case isOverallStatsShowArchived /// 总体统计是否显示已归档
        
        static func keyPrefix() -> String? {
            return "FocusSetting"
        }
    }

    /// 周开始日
    @CloudStored(key: Key.firstWeekday.name, defaultValue: .monday)
    var firstWeekday: Weekday
    
    /// 添加计时器到顶部
    @CloudStored(key: Key.addTimerOnTop.name, defaultValue: false)
    var addTimerOnTop: Bool
    
    /// 最小有效记录时长
    @CloudStored(key: Key.minimumRecordDuration.name, defaultValue: FocusSetting.defaultMinimumRecordDuration)
    var minimumRecordDuration: Duration
    
    /// 单次微调时长
    @CloudStored(key: Key.adjustStepDuration.name, defaultValue: FocusSetting.defaultAdjustStepDuration)
    var adjustStepDuration: Duration
    
    /// 正计时最大时长
    @CloudStored(key: Key.stopwatchMaxDuration.name, defaultValue: FocusSetting.defaultStopwatchMaxDuration)
    var stopwatchMaxDuration: Duration
    
    /// 番茄钟是否自动开始专注
    @CloudStored(key: Key.pomodoroAutoStartFocus.name, defaultValue: true)
    var pomodoroAutoStartFocus: Bool
    
    /// 番茄钟是否自动开始休息
    @CloudStored(key: Key.pomodoroAutoStartBreak.name, defaultValue: true)
    var pomodoroAutoStartBreak: Bool
    
    /// 步骤计时器是否自动开始下一步
    @CloudStored(key: Key.steppedAutoStartNext.name, defaultValue: true)
    var steppedAutoStartNext: Bool
    
    /// 浮窗计时器是否隐藏下一步按钮
    @CloudStored(key: Key.isFloatingTimerNextButtonHidden.name, defaultValue: false)
    var isFloatingTimerNextButtonHidden: Bool
    
    /// 翻页时钟自动隐藏小时位
    @CloudStored(key: Key.flipClockAutoHideHour.name, defaultValue: true)
    var flipClockAutoHideHour: Bool
    
    /// 总体统计是否显示已归档
    @CloudStored(key: Key.isOverallStatsShowArchived.name, defaultValue: true)
    var isOverallStatsShowArchived: Bool
    
    static let shared = FocusSetting()
    
    private init() {}
    
    var validatedMinimumRecordDuration: Duration {
        return clampedValue(minimumRecordDuration,
                            Self.minimumRecordMinuteRange.lowerBound * SECONDS_PER_MINUTE,
                            Self.minimumRecordMinuteRange.upperBound * SECONDS_PER_MINUTE)
    }

    var validatedAdjustStepDuration: Duration {
       return clampedValue(adjustStepDuration,
                           Self.adjustStepMinuteRange.lowerBound * SECONDS_PER_MINUTE,
                           Self.adjustStepMinuteRange.upperBound * SECONDS_PER_MINUTE)
    }
    
    var validatedStopwatchMaxDuration: Duration {
        if stopwatchMaxDuration < Self.minimumStopwatchDuration {
            stopwatchMaxDuration = Self.minimumStopwatchDuration
        }
        
        return stopwatchMaxDuration
    }
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
}

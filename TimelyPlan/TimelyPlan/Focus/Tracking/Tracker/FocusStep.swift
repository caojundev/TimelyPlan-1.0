//
//  FocusStep.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/6.
//

import Foundation
import UIKit

protocol FocusStepsProvider: Any{
    
    /// 返回计时器步骤
    func steps() -> [FocusStep]
}
   
enum FocusStepMode: String, Codable, TPMenuRepresentable {
    case focus   /// 专注
    case `break` /// 休息
    
    var iconName: String? {
        switch self {
        case .focus:
            return "focus_timer_stepMode_focus_24"
        case .break:
            return "focus_timer_stepMode_break_24"
        }
    }
}

/// 专注步骤
class FocusStep: Codable, Equatable, TPHexColorConvertible {

    /// 计时方式
    enum TimerType: Int, Codable {
        case countdown /// 倒计时
        case stopwatch /// 正计时
    }
    
    /// 唯一标识
    var identifier: String?
    
    /// 名称
    var name: String?
    
    /// 步骤颜色
    var colorHex: String? = "476AFF"
    
    /// 模式
    var mode: FocusStepMode = .focus
    
    /// 计时方式
    var timerType: TimerType? = .countdown
    
    /// 目标时长
    var duration: TimeInterval = 0.0

    /// 是否自动开始
    var autoStart: Bool?

    /// 开始日期
    var startDate: Date?

    /// 暂停信息数组
    var pauses: [TimeFragment]?

    /// 步骤备注
    var note: String?
    
    // MARK: - Getters
    /// 是否已经开始
    var isStarted: Bool {
        guard let startDate = startDate else {
            return false
        }

        let now = Date()
        return now >= startDate /// 当前日期在开始日期之后
    }
    
    /// 结束日期
    var endDate: Date? {
        guard let startDate = startDate else {
            /// 未开始
            return nil
        }
        
        let targetInterval = duration
        let pauseInterval = pauses?.interval ?? 0.0
        let interval = targetInterval + pauseInterval
        return startDate.addingTimeInterval(interval)
    }
    
    // MARK: - Equatable
    static func == (lhs: FocusStep, rhs: FocusStep) -> Bool {
        return lhs.identifier == rhs.identifier &&
        lhs.name == rhs.name &&
        lhs.mode == rhs.mode &&
        lhs.timerType == rhs.timerType &&
        lhs.duration == rhs.duration &&
        lhs.autoStart == rhs.autoStart &&
        lhs.startDate == rhs.startDate &&
        lhs.pauses == rhs.pauses &&
        lhs.note == rhs.note
    }
    
    convenience init(name: String?,
                     mode: FocusStepMode,
                     timerType: TimerType,
                     duration: TimeInterval,
                     autoStart: Bool) {
        self.init()
        self.identifier = UUID().uuidString
        self.name = name
        self.mode = mode
        self.timerType = timerType
        self.duration = duration
        self.autoStart = autoStart
    }
}

// MARK: - 便捷构造类方法
extension FocusStep {
    
    static func pomodoroFocusStep(duration: TimeInterval, autoStart: Bool) -> FocusStep {
        let step = FocusStep(name: resGetString("Focus"),
                             mode: .focus,
                             timerType: .countdown,
                             duration: duration,
                             autoStart: autoStart)
        return step
    }
    
    static func pomodoroShortBreakStep(duration: TimeInterval, autoStart: Bool) -> FocusStep {
        let step = FocusStep(name: resGetString("Short Break"),
                             mode: .break,
                             timerType: .countdown,
                             duration: duration,
                             autoStart: autoStart)
        return step
    }
    
    static func pomodoroLongBreakStep(duration: TimeInterval, autoStart: Bool) -> FocusStep {
        let step = FocusStep(name: resGetString("Long Break"),
                             mode: .break,
                             timerType: .countdown,
                             duration: duration,
                             autoStart: autoStart)
        return step
    }
    
    /// 倒计时步骤
    static func countdownStep(duration: TimeInterval, autoStart: Bool) -> FocusStep {
        var step = FocusStep(name: resGetString("Focus"),
                             mode: .focus,
                             timerType: .countdown,
                             duration: duration,
                             autoStart: autoStart)
        step.color = kFocusCountdownTimerColor
        return step
    }
    
    /// 正计时步骤
    static func stopwatchStep(autoStart: Bool) -> FocusStep {
        let duration = focus.setting.getStopwatchDuration()
        var step = FocusStep(name: resGetString("Focus"),
                             mode: .focus,
                             timerType: .stopwatch,
                             duration: TimeInterval(duration),
                             autoStart: autoStart)
        step.color = kFocusStopwatchTimerColor
        return step
    }
    
}

extension FocusStep {
    
    /// 获取步骤对应的记录时间线
    func recordTimeline() -> FocusRecordTimeline? {
        guard let startDate = self.startDate,
                let endDate = self.endDate,
                self.duration > 0 else {
            return nil
        }
        
        guard let pauses = self.pauses, pauses.count > 0 else {
            let recordDuration = FocusRecordDuration(type: .focus, interval: self.duration)
            return FocusRecordTimeline(startDate: startDate, recordDurations: [recordDuration])
        }
        
        var recordDurations = [FocusRecordDuration]()
        var previousDate = startDate
        for pause in pauses {
            let focusInterval = pause.startDate.timeIntervalSince(previousDate)
            if focusInterval > 0 {
                let focusDuration = FocusRecordDuration(type: .focus, interval: focusInterval)
                recordDurations.append(focusDuration)
            }

            let pauseDuration = FocusRecordDuration(type: .pause, interval: pause.interval)
            recordDurations.append(pauseDuration)
            
            previousDate = pause.endDate
        }
        
        /// 最后一段专注
        let focusInterval = endDate.timeIntervalSince(previousDate)
        if focusInterval > 0 {
            let focusDuration = FocusRecordDuration(type: .focus, interval: focusInterval)
            recordDurations.append(focusDuration)
        }
        
        return FocusRecordTimeline(startDate: startDate, recordDurations: recordDurations)
    }
    
    /// 获取步骤对应的专注记录
    func record(with timer: FocusTimerRepresentable?) -> FocusRecord? {
        guard let timeline = self.recordTimeline() else {
            return nil
        }
        
        let record = FocusRecord(timeline: timeline)
        record.timer = timer
        record.color = self.color
        record.note = self.note
        let calculator = FocusScoreCalculator()
        let score = calculator.calculateFocusScore(focusDuration: timeline.focusInterval,
                                                   pauseCount: Double(timeline.pauseCount),
                                                   pauseDuration: timeline.pauseInterval)
        record.score = Int(score)
        return record
    }
}

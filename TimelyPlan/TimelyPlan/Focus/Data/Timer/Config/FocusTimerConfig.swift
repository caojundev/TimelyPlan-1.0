//
//  FocusTimer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/13.
//

import Foundation

/// 专注计时器模式
enum FocusTimerType: Int, Codable, TPMenuRepresentable {
    
    case pomodoro  /// 番茄钟
    case countdown /// 倒计时
    case stopwatch /// 正计时
    case stepped   /// 步骤
    
    /// 所有类型数组
    static let allTypes: [FocusTimerType] = [.stepped, .pomodoro, .countdown, .stopwatch]
    
    /// 默认类型数组
    static let defaultTypes: [FocusTimerType] = [.pomodoro, .countdown, .stopwatch]
    
    /// 默认模式
    static let defaultType: FocusTimerType = .pomodoro
    
    static func titles() -> [String] {
        return ["Pomodoro",
                "Countdown",
                "Stopwatch",
                "Stepped"]
    }

    var iconName: String? {
        let name: String
        switch self {
        case .pomodoro:
            name = "pomodoro"
        case .countdown:
            name = "countdown"
        case .stopwatch:
            name = "stopwatch"
        case .stepped:
            name = "stepped"
        }
        
        return "focus_timer_" + name + "_32"
    }

    var attributedTitle: ASAttributedString {
        if let image = self.iconImage {
            return .string(image: image,
                           imageSize: kIndicatorMediumSize,
                           imageColor: .label,
                           trailingText: title,
                           separator: " ")
        }
        
        return "\(title)"
    }
}

public class FocusTimerConfig: NSObject, NSCopying, Codable {

    static var defaultConfig: FocusTimerConfig {
        return .pomodoroConfig
    }
    
    /// 类型
    var timerType: FocusTimerType? = .pomodoro
    
    /// 番茄时钟
    var pomodoroConfig: FocusPomodoroConfig?
    
    /// 倒计时
    var countdownConfig: FocusCountdownConfig?
    
    /// 正计时
    var stopwatchConfig: FocusStopwatchConfig?
    
    /// 步骤计时
    var steppedConfig: FocusSteppedConfig?
    
    /// 是否可用
    var isEnabled: Bool {
        guard timerType == .stepped else {
            return true
        }

        if let steps = steppedConfig?.timerSteps, steps.count > 0 {
            return true
        }
        
        return false
    }
    
    convenience init(config: FocusPomodoroConfig) {
        self.init()
        self.timerType = .pomodoro
        self.pomodoroConfig = config
    }
    
    convenience init(config: FocusCountdownConfig) {
        self.init()
        self.timerType = .countdown
        self.countdownConfig = config
    }
    
    convenience init(config: FocusStopwatchConfig) {
        self.init()
        self.timerType = .stopwatch
        self.stopwatchConfig = config
    }
    
    convenience init(config: FocusSteppedConfig) {
        self.init()
        self.timerType = .stepped
        self.steppedConfig = config
    }
    
    static var pomodoroConfig: FocusTimerConfig  {
        return FocusTimerConfig(config: FocusPomodoroConfig())
    }
    
    static var countdownConfig: FocusTimerConfig  {
        return FocusTimerConfig(config: FocusCountdownConfig())
    }
    
    static var stopwatchConfig: FocusTimerConfig  {
        return FocusTimerConfig(config: FocusStopwatchConfig())
    }
    
    static var steppedConfig: FocusTimerConfig  {
        return FocusTimerConfig(config: FocusSteppedConfig())
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(timerType)
        hasher.combine(pomodoroConfig)
        hasher.combine(countdownConfig)
        hasher.combine(stopwatchConfig)
        hasher.combine(steppedConfig)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FocusTimerConfig else { return false }
        if self === other { return true }
        let bEqual = timerType == other.timerType &&
                    pomodoroConfig == other.pomodoroConfig &&
                    countdownConfig == other.countdownConfig &&
                    stopwatchConfig == other.stopwatchConfig &&
                    steppedConfig == other.steppedConfig
        return bEqual
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = FocusTimerConfig()
        copy.timerType = timerType
        copy.pomodoroConfig = pomodoroConfig
        copy.countdownConfig = countdownConfig
        copy.stopwatchConfig = stopwatchConfig
        copy.steppedConfig = steppedConfig
        return copy
    }
    
    // MARK: - Summary
    var attributedSummary: ASAttributedString? {
        let timerType = self.timerType ?? .defaultType
        let title = timerType.attributedTitle
        guard let detail = detail else {
            return title
        }
        
        return title + " • \(detail)"
    }
    
    var summary: String? {
        let timerType = self.timerType ?? .defaultType
        let title = timerType.title
        guard let detail = detail else  {
            return title
        }
        
        return title + " • \(detail)"
    }
    
    var detail: String? {
        let timerType = self.timerType ??  .defaultType
        switch timerType {
        case .pomodoro:
            let timer = pomodoroConfig ?? FocusPomodoroConfig()
            return timer.info
        case .countdown:
            let timer = countdownConfig ?? FocusCountdownConfig()
            return timer.info
        case .stopwatch:
            return nil
        case .stepped:
            let timer = steppedConfig ?? FocusSteppedConfig()
            return timer.info
        }
    }
    
    // MARK: - Event
    func event() -> FocusEvent {
        let stepsProvider: FocusStepsProvider
        let timerType = timerType ?? .defaultType
        switch timerType {
        case .pomodoro:
            stepsProvider = pomodoroConfig ?? FocusPomodoroConfig()
        case .countdown:
            stepsProvider = countdownConfig ?? FocusCountdownConfig()
        case .stopwatch:
            stepsProvider = stopwatchConfig ?? FocusStopwatchConfig()
        case .stepped:
            stepsProvider = steppedConfig ?? FocusSteppedConfig()
        }
        
        let steps = stepsProvider.steps()
        
        /// 创建事件
        let event = FocusEvent()
        event.timerConfig = self
        event.steps = steps
        return event
    }
}

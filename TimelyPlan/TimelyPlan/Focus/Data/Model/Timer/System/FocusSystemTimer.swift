//
//  FocusSystemTimer.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/4.
//

import Foundation

/// 默认计时器标识
struct FocusSystemTimerIdentifier {
    static var pomodoro = "pomodoro"
    static var countdown = "countdown"
    static var stopwatch = "stopwatch"
    static var stepped = "stepped"
    
    private static let typesDic: [String: FocusTimerType] = [
        pomodoro: .pomodoro,
        countdown: .countdown,
        stopwatch: .stopwatch,
        stepped: .stepped
    ]
    
    /// 获取特定计时器类型唯一标识
    static func identifier(for timerType: FocusTimerType) -> String {
        switch timerType {
        case .pomodoro:
            return pomodoro
        case .countdown:
            return countdown
        case .stopwatch:
            return stopwatch
        case .stepped:
            return stepped
        }
    }
    
    /// 获取系统标识对应的计时器类型
    static func timerType(for identifier: String) -> FocusTimerType? {
        return typesDic[identifier]
    }
    
    /// 所有标识数组
    static var allIdentifiers = [pomodoro, countdown, stopwatch, stepped]
    
    /// 是否包含标识
    static func contains(_ identifier: String) -> Bool {
        return allIdentifiers.contains(identifier)
    }
}


class FocusSystemTimer: NSObject, FocusTimerRepresentable {
    
    var timerColor: UIColor {
        return .primary
    }
    
    var timerType: FocusTimerType {
        return .defaultType
    }
    
    var timerDescription: String? {
        return nil
    }
    
    var timerInfo: TextRepresentable? {
        let color = kFocusTimerDefaultColor
        let attributedInfo: ASAttributedString = "\("●", .foreground(color)) \(timerType.title)"
        return attributedInfo
    }
    
    var timerConfig: FocusTimerConfig? {
        return nil
    }
    
    var name: String? {
        get {
            return timerType.title
        }
        
        set { }
    }
    
    var identifier: String {
        get {
            return FocusSystemTimerIdentifier.identifier(for: timerType)
        }
        
        set { }
    }
    
    /// 获取默认计时器特征
    var feature: TimerFeature? {
        return TimerFeature(identifier: identifier)
    }

    /// 获取计时器特征对应的计时器类型
    static func timerType(for feature: TimerFeature) -> FocusTimerType? {
        return FocusSystemTimerIdentifier.timerType(for: feature.identifier)
    }
    
    static func timer(with config: FocusPomodoroConfig?) -> FocusSystemTimer {
        return FocusSystemPomodoroTimer(config: config)
    }
    
    static func timer(with config: FocusCountdownConfig?) -> FocusSystemTimer {
        return FocusSystemCountdownTimer(config: config)
    }
    
    static func timer(with config: FocusStopwatchConfig?) -> FocusSystemTimer {
        return FocusSystemStopwatchTimer(config: config)
    }
}

/// 默认番茄计时器
class FocusSystemPomodoroTimer: FocusSystemTimer {
    
    var config: FocusPomodoroConfig

    override var name: String? {
        get {
            return resGetString("Default Pomodoro")
        }
        
        set { }
    }
    
    override var timerType: FocusTimerType {
        return .pomodoro
    }
    
    override var timerDescription: String? {
        return self.config.info
    }
    
    override var timerConfig: FocusTimerConfig? {
        return FocusTimerConfig(config: config)
    }

    init(config: FocusPomodoroConfig? = nil) {
        self.config = config ?? FocusPomodoroConfig()
    }
}

/// 默认倒计时
class FocusSystemCountdownTimer: FocusSystemTimer {

    var config: FocusCountdownConfig
    
    override var name: String? {
        get {
            return resGetString("Default Countdown")
        }
        
        set { }
    }
    
    override var timerType: FocusTimerType {
        return .countdown
    }
    
    override var timerDescription: String? {
        return self.config.info
    }
    
    override var timerConfig: FocusTimerConfig? {
        return FocusTimerConfig(config: config)
    }

    init(config: FocusCountdownConfig? = nil) {
        self.config = config ?? FocusCountdownConfig()
    }
}

/// 默认正计时
class FocusSystemStopwatchTimer: FocusSystemTimer {

    var config: FocusStopwatchConfig
    
    override var name: String? {
        get {
            return resGetString("Default Stopwatch")
        }
        
        set { }
    }
    
    override var timerType: FocusTimerType {
        return .stopwatch
    }
    
    override var timerConfig: FocusTimerConfig? {
        return FocusTimerConfig(config: config)
    }

    init(config: FocusStopwatchConfig? = nil) {
        self.config = config ?? FocusStopwatchConfig()
    }
}


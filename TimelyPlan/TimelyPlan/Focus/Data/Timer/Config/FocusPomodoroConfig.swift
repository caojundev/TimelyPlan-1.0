//
//  PomodoroTimerConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/12.
//

import Foundation

enum FocusPomodoroPhase: Int, TPMenuRepresentable {
    case focus      // 专注时间
    case shortBreak // 短休息时间
    case longBreak  // 长休息时间

    static func titles() -> [String] {
        return ["Focus",
                "Short Break",
                "Long Break"]
    }
}

struct FocusPomodoroConfig: Hashable, Equatable, Codable {
//    static let defaultFocusDuration: TimeInterval = 25 * 60
//    static let minimumFocusDuration: TimeInterval = 5 * 60
//    static let maximumFocusDuration: TimeInterval = 180 * 60
//
//    static let defaultShortBreakDuration: TimeInterval = 5 * 60
//    static let minimumShortBreakDuration: TimeInterval = 5 * 60
//    static let maximumShortBreakDuration: TimeInterval = 30 * 60
//
//    static let defaultLongBreakDuration: TimeInterval = 15 * 60
//    static let minimumLongBreakDuration: TimeInterval = 5 * 60
//    static let maximumLongBreakDuration: TimeInterval = 60 * 60

    static let defaultFocusDuration: TimeInterval = 1 * 60
    static let minimumFocusDuration: TimeInterval = 1 * 60
    static let maximumFocusDuration: TimeInterval = 180 * 60
    
    static let defaultShortBreakDuration: TimeInterval = 1 * 60
    static let minimumShortBreakDuration: TimeInterval = 1 * 60
    static let maximumShortBreakDuration: TimeInterval = 30 * 60
    
    static let defaultLongBreakDuration: TimeInterval = 1 * 60
    static let minimumLongBreakDuration: TimeInterval = 1 * 60
    static let maximumLongBreakDuration: TimeInterval = 60 * 60
    
    static let defaultPomosCountPerCycle = 4
    static let minimumPomosCountPerCircle = 2
    static let maximumPomosCountPerCircle = 8

    /// 专注颜色
    static var focusColor: UIColor = Color(0x4A4DFF)

    /// 短休颜色
    static var shortBreakColor = Color(0xFFB43E)
    
    /// 长休颜色
    static var longBreakColor = Color(0xF66464)
    
    /// 工作时长
    private var _focusDuration: TimeInterval?
    var focusDuration: TimeInterval {
        get {
            if let focusDuration = _focusDuration {
                return focusDuration
            }
            
            return Self.defaultFocusDuration
        }
        
        set {
            _focusDuration = newValue
        }
    }
    
    /// 短休时长
    private var _shortBreakDuration: TimeInterval?
    var shortBreakDuration: TimeInterval {
        get {
            if let shortBreakDuration = _shortBreakDuration {
                return shortBreakDuration
            }
            
            return Self.defaultShortBreakDuration
        }
        
        set {
            _shortBreakDuration = newValue
        }
    }

    /// 长休时长
    private var _longBreakDuration: TimeInterval?
    var longBreakDuration: TimeInterval {
        get {
            if let longBreakDuration = _longBreakDuration {
                return longBreakDuration
            }
            
            return Self.defaultLongBreakDuration
        }
        
        set {
            _longBreakDuration = newValue
        }
    }
    
    /// 一个周期番茄数目，默认为4
    fileprivate var _pomosCountPerCycle: Int?
    var pomosCountPerCycle: Int {
        get {
            if let pomosCountPerCycle = _pomosCountPerCycle {
                return pomosCountPerCycle
            }
            
            return Self.defaultPomosCountPerCycle
        }
        
        set {
            _pomosCountPerCycle = newValue
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case _focusDuration = "focus"
        case _shortBreakDuration = "shortBreak"
        case _longBreakDuration = "longBreak"
        case _pomosCountPerCycle = "pomosCountPerCycle"
    }
    
    /// 每一轮时间长度
    public func durationPerRound() -> TimeInterval {
        let focusCount = pomosCountPerCycle
        let shortBreakCount = focusCount - 1
        let duration = Double(focusCount) * focusDuration + Double(shortBreakCount) * shortBreakDuration + longBreakDuration
        return duration
    }
    
    // MARK: - 信息
    var info: String {
        var infos = [String]()
        let format = resGetString("%ldm")
        var focusString = String(format: format, focusDuration.minutes)
        focusString = "\(pomosCountPerCycle)×\(focusString)"
        infos.append(focusString)
        let shortBreakString = String(format: format, shortBreakDuration.minutes)
        infos.append(shortBreakString)
        let longBreakString = String(format: format, longBreakDuration.minutes)
        infos.append(longBreakString)
        return infos.joined(separator: "•")
    }
    
    var attributedInfo: ASAttributedString {
        var infos = [ASAttributedString]()
        
        let format = resGetString("%ldm")
        
        let focusDuration = String(format: format, focusDuration.minutes)
        let focusFormat = resGetString("Focus %@")
        let focusAttributedInfo: ASAttributedString = .string(format: focusFormat,
                                                              stringParameters: [focusDuration])
        infos.append(focusAttributedInfo)

        let shortBreakDuration = String(format: format, shortBreakDuration.minutes)
        let shortBreakFormat = resGetString("Short Break %@")
        let shortBreakAttributedInfo: ASAttributedString = .string(format: shortBreakFormat,
                                                                   stringParameters: [shortBreakDuration])
        infos.append(shortBreakAttributedInfo)
        
        let longBreakDuration = String(format: format, longBreakDuration.minutes)
        let longBreakFormat = resGetString("Long Break %@")
        let longBreakAttributedInfo: ASAttributedString = .string(format: longBreakFormat,
                                                                  stringParameters: [longBreakDuration])
        infos.append(longBreakAttributedInfo)
        return infos.joined(separator: " • ")
    }
    
    // MARK: - 获取索引处对应信息
    func fragment(atIndex index: Int?) -> PomodoroFragment? {
        guard let index = index else {
            return nil
        }

        let stepsCount = pomosCountPerCycle * 2
        var stepDurations = [TimeInterval]()
        for i in 0..<stepsCount {
            if i % 2 == 0 {
                /// 专注
                stepDurations.append(focusDuration)
            } else if i == stepsCount - 1 {
                /// 长休
                stepDurations.append(longBreakDuration)
            } else {
                /// 短休
                stepDurations.append(shortBreakDuration)
            }
        }
        
        let stepIndex = index % stepsCount
        var duration: TimeInterval = 0.0
        for i in 0...stepIndex {
            duration += stepDurations[i]
        }
        
        let totalDuration = durationPerRound()
        let to = duration / totalDuration
        let from = to - stepDurations[stepIndex] / totalDuration
        return PomodoroFragment(fromProgress: from, toProgress: to)
    }
    
    func phase(atIndex index: Int?) -> FocusPomodoroPhase? {
        guard let index = index else {
            return nil
        }

        let stepsCount = pomosCountPerCycle * 2
        let stepIndex = index % stepsCount
        if stepIndex % 2 == 0 {
            /// 专注
            return .focus
        } else if stepIndex == stepsCount - 1 {
            /// 长休
            return .longBreak
        } else {
            /// 短休
            return .shortBreak
        }
    }
}

extension FocusPomodoroConfig: FocusStepsProvider {
    
    func steps() -> [FocusStep] {
        let autoStartFocus = focus.setting.getPomodoroAutoStartFocus()
        let autoStartBreak = focus.setting.getPomodoroAutoStartBreak()
        var steps = [FocusStep]()
        for i in 1...pomosCountPerCycle {
            var focusStep = FocusStep.pomodoroFocusStep(duration: focusDuration,
                                                        autoStart: autoStartFocus)
            focusStep.color = Self.focusColor
            steps.append(focusStep)
            
            if i < pomosCountPerCycle {
                var shortBreakStep = FocusStep.pomodoroShortBreakStep(duration: shortBreakDuration,
                                                                      autoStart: autoStartBreak)
                shortBreakStep.color = Self.shortBreakColor
                steps.append(shortBreakStep)
            }
        }
        
        var longBreakStep = FocusStep.pomodoroLongBreakStep(duration: longBreakDuration,
                                                            autoStart: autoStartBreak)
        longBreakStep.color = Self.longBreakColor
        steps.append(longBreakStep)
        return steps
    }
}

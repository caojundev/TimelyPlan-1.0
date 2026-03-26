//
//  FocusDefaultTimerManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/4.
//

import Foundation

class FocusSystemTimerManager {

    private lazy var pomodoroTimer: FocusSystemPomodoroTimer = {
        let config = FocusState.shared.pomodoroConfig
        return FocusSystemPomodoroTimer(config: config)
    }()
    
    private var countdownTimer: FocusSystemCountdownTimer = {
        let config = FocusState.shared.countdownConfig
        return FocusSystemCountdownTimer(config: config)
    }()
    
    private var stopwatchTimer = FocusSystemStopwatchTimer()
    
    /// 所有默认计时器
    var allTimers: [FocusSystemTimer] {
        return [pomodoroTimer, countdownTimer, stopwatchTimer]
    }
    
    /// 默认的计时器
    var defaultTimer: FocusSystemTimer {
        return pomodoroTimer
    }
    
    /// 获取特征值对应的默认计时器
    func timer(of feature: TimerFeature) -> FocusSystemTimer? {
        guard let timerType = FocusSystemTimer.timerType(for: feature) else {
            return nil
        }
        
        switch timerType {
        case .pomodoro:
            return pomodoroTimer
        case .countdown:
            return countdownTimer
        case .stopwatch:
            return stopwatchTimer
        case .stepped:
            return nil
        }
    }
}

//
//  FocusDefaultTimerManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/4.
//

import Foundation

class FocusSystemTimerManager {

    private var pomodoroTimer: FocusSystemPomodoroTimer
    
    private var countdownTimer: FocusSystemCountdownTimer
    
    private var stopwatchTimer: FocusSystemStopwatchTimer
    
    /// 所有默认计时器
    var allTimers: [FocusSystemTimer] {
        return [pomodoroTimer, countdownTimer, stopwatchTimer]
    }
    
    /// 默认的计时器
    var defaultTimer: FocusSystemTimer {
        return pomodoroTimer
    }
    
    init() {
        self.pomodoroTimer = FocusSystemPomodoroTimer()
        self.countdownTimer = FocusSystemCountdownTimer()
        self.stopwatchTimer = FocusSystemStopwatchTimer()
    }
    
    /// 获取特征值对应的默认计时器
    func timer(of feature: TimerFeature) -> FocusSystemTimer? {
        guard let timerType = feature.timerType else {
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

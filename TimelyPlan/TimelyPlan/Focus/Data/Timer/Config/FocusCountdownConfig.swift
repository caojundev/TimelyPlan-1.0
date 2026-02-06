//
//  FocusCountdownConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/12.
//

import Foundation

struct FocusCountdownConfig: Hashable,
                            Equatable,
                            Codable {
    
    /// 默认时长
    static var defaultMinutes: Int = 25
    static var defaultDuration = TimeInterval(defaultMinutes * SECONDS_PER_MINUTE)
    
    /// 倒计时时间长度
    var duration: TimeInterval?
    
    /// 分钟数
    var minutes: Int {
        let duration = duration ?? Self.defaultDuration
        return Int(duration) / SECONDS_PER_MINUTE
    }
    
    // MARK: - 信息
    var info: String {
        let format: String = resGetString("%ldm")
        return String(format: format, minutes)
    }
}

extension FocusCountdownConfig: FocusStepsProvider {
    
    func steps() -> [FocusStep] {
        let stepDuration: TimeInterval
        if let duration = duration, duration > TimeInterval(SECONDS_PER_MINUTE) {
            stepDuration = duration
        } else {
            stepDuration = Self.defaultDuration
        }
        
        let step = FocusStep.countdownStep(duration: stepDuration,
                                           autoStart: true)
        return [step]
    }
}
    

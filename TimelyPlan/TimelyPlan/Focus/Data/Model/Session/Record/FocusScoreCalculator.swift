//
//  FocusScoreCalculator.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/22.
//

import Foundation

class FocusScoreCalculator {
    
    let maxPauseCount: Double = 3    // 最大暂停次数
    let maxPauseDuration: Double = Double(2 * SECONDS_PER_MINUTE) // 最大暂停时长
    
    let focusDurationWeight: Double = 0.2 // 专注时间权重因子
    let pauseCountWeight: Double = 0.4 // 暂停次数权重因子
    let pauseDurationWeight: Double = 0.4 // 暂停时长权重因子
    
    func calculateFocusScore(focusDuration: TimeInterval,
                             pauseCount: Double,
                             pauseDuration: TimeInterval) -> Double {
        let focusTimeScore = (focusDuration / Double(5 * SECONDS_PER_MINUTE)) * 100
        let pauseCountScore = (1 - (pauseCount / maxPauseCount)) * 100
        let pauseDurationScore = (1 - (pauseDuration / maxPauseDuration)) * 100
        let finalScore = focusTimeScore * focusDurationWeight + pauseCountScore * pauseCountWeight + pauseDurationScore * pauseDurationWeight
        return min(max(0, finalScore), 100)
    }
}

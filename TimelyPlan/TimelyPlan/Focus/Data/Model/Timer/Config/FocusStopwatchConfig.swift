//
//  FocusStopwatchConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/12.
//

import Foundation

struct FocusStopwatchConfig: Hashable,
                            Equatable,
                            Codable,
                            FocusStepsProvider {
    
    /// 返回计时器步骤
    func steps() -> [FocusStep] {
        let step = FocusStep.stopwatchStep(autoStart: true)
        return [step]
    }
}

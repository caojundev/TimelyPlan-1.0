//
//  FocusTimerInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/7.
//

import Foundation
import UIKit

struct FocusTimerInfo {
    
    var step: FocusStep?
    
    /// 当前状态
    var state: FocusEvent.State

    /// 步骤索引
    var stepIndex: Int?
    
    /// 所有步骤数目
    var stepsCount: Int?

    /// 已过时间
    var elapsedDuration: TimeInterval
    
    var timerType: FocusStep.TimerType {
        return step?.timerType ?? .countdown
    }
    
    /// 步骤名称
    var stepName: String? {
        return step?.name
    }
    
    /// 颜色
    var color: UIColor? {
        return step?.color
    }
    
    /// 总时间
    var totalDuration: TimeInterval {
        return step?.duration ?? 0.0
    }

    /// 是否有下一步
    var hasNextStep: Bool {
        guard let stepIndex = stepIndex, let stepsCount = stepsCount else {
            return false
        }

        return stepIndex + 1 < stepsCount
    }
    
    /// 剩余时长
    var remainDuration: TimeInterval {
        let remain = totalDuration - elapsedDuration
        return max(remain, 0.0)
    }
    
    /// 是否暂停中
    var isPaused: Bool {
        return state == .focusPaused || state == .breakPaused
    }
    
    /// 步骤索引和名称字符串
    var stepIndexAndNameString: String? {
        var infos: [String] = []
        if let stepIndex = stepIndex, let stepsCount = stepsCount {
            infos.append("\(stepIndex+1)/\(stepsCount)")
        }
        
        if let stepName = stepName {
            infos.append(stepName)
        }
        
        if infos.count == 0 {
            return nil
        }
        
        return infos.joined(separator: " • ")
    }

    /// 结束信息对象
    static var finishedInfo: FocusTimerInfo {
        return FocusTimerInfo(step: nil,
                              state: .finished,
                              stepIndex: nil,
                              stepsCount: nil, elapsedDuration: 0)
    }
    
    /// 获取计时器信息对应的事件操作类型数组
    func eventActionTypes() -> [FocusEventActionType] {
        var types: [FocusEventActionType] = []
        switch state {
        case .notStarted, .waitingForFocus, .waitingForBreak:
            types = [.start]
        case .focusing, .breaking:
            types = [.pause]
        case .focusPaused, .breakPaused:
            types = [.resume]
        case .finished:
            types = []
        }
        
        if hasNextStep {
            types.append(.next)
        }
        
        return types
    }
    
}

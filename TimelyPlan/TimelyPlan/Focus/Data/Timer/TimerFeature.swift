//
//  TimerFeature.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/4.
//

import Foundation
import UIKit

/// 计时器特征信息
struct TimerFeature: Codable, Hashable, Equatable {

    /// 标识
    var identifier: String
  
    /// 计时器类型
    var timerType: FocusTimerType?
    
    /// 快照名称
    var shotName: String?

    /// 表示未知特征信息
    static var noneIdentifier = "None"
    static var none: TimerFeature {
        return TimerFeature(identifier: noneIdentifier)
    }
    
    var isNone: Bool {
        return identifier == TimerFeature.noneIdentifier
    }
    
    /// 是否为默认计时器
    var isDefaultTimer: Bool {
        return FocusSystemTimerIdentifier.allIdentifiers.contains(identifier)
    }
    
    var isUserTimer: Bool {
        return !isDefaultTimer
    }
    
    /// 获取特征信息对应计时器
    var timer: FocusTimerRepresentable? {
        return focus.getTimer(withFeature: self)
    }
    
    /// 提供自定义的哈希值计算
    func hash(into hasher: inout Hasher) {
        hasher.combine(timerType)
        hasher.combine(identifier)
        hasher.combine(shotName)
    }
    
}

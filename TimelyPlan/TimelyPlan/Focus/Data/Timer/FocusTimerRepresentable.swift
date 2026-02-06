//
//  FocusTimerRepresentable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/2.
//

import Foundation

protocol FocusTimerRepresentable: AnyObject {

    var identifier: String? { get set }

    /// 名称
    var name: String? { get set }
    
    /// 计时器类型
    var timerType: FocusTimerType { get }
    
    /// 计时器描述
    var timerInfo: String? { get }
    
    /// 计时器配置
    var timerConfig: FocusTimerConfig? { get }
    
    /// 计时器特征
    var feature: TimerFeature?  { get }
    
}

extension FocusTimerRepresentable {
    
    /// 判断是否为相同的计时器
    func isSame(as other: FocusTimerRepresentable) -> Bool {
        guard timerType == other.timerType else {
            return false
        }
        
        return identifier == other.identifier
    }
}

//
//  FocusTimerRepresentable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/2.
//

import Foundation
import UIKit

protocol FocusTimerRepresentable: AnyObject {

    var identifier: String? { get set }
    
    /// 名称
    var name: String? { get set }
    
    /// 计时器类型
    var timerType: FocusTimerType { get }
    
    /// 计时器特征
    var feature: TimerFeature?  { get }
    
    /// 计时器描述
    var timerDescription: String? { get }
    
    /// 计时器信息
    var timerInfo: TextRepresentable? { get }
    
    /// 计时器配置
    var timerConfig: FocusTimerConfig? { get }
    
    /// 颜色
    var timerColor: UIColor { get }
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

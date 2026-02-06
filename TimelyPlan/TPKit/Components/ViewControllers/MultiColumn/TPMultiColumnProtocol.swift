//
//  TPMultiColumnProtocol.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/11.
//

import Foundation

enum TPMultiColumnStatus: UInt {
    case primary = 1  // 第一活动栏
    case secondary    // 已呈现
    case hidden       // 左侧隐藏
}

protocol TPMultiColumnProtocol: AnyObject {
    
    /// 多边栏状态
    var multiColumnStatus: TPMultiColumnStatus { get set }
    
    /// 从非活动状态转变第一活动状态进度
    func becomeFirstActive(with progress: CGFloat)
    
    /// 从第一活动状态转变成非活动状态进度
    func resignFirstActive(with progress: CGFloat)
    
    /// 点击了容器视图的遮罩
    func didClickMask(for containerView: TPColumnContainerView)
}

extension TPMultiColumnProtocol {
    
    func becomeFirstActive(with progress: CGFloat) {
        
    }
    
    func resignFirstActive(with progress: CGFloat) {
        
    }

    func didClickMask(for containerView: TPColumnContainerView) {
        
    }
}

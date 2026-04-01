//
//  TPDragPreviewViewProviding.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/1.
//

import Foundation

protocol TPDragPreviewViewProviding {
    
    /// 返回用于拖动时跟随手指移动的视图。
    /// - Returns: 一个 UIView 实例，通常是一个快照或简化版的视图。
    func dragPreviewView() -> UIView?
    
    /// 开始时所处的位置，相对于单元格
    func beginPosition() -> CGPoint
    
    /// 结束时所处的位置，相对于单元格
    func endPosition() -> CGPoint
}

extension TPDragPreviewViewProviding {
    
    func dragPreviewView() -> UIView? {
        return nil
    }
    
    func beginPosition() -> CGPoint {
        return .zero
    }
    
    func endPosition() -> CGPoint {
        return beginPosition()
    }
}

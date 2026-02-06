//
//  TodoIndentationGuideLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/1.
//

import Foundation
import QuartzCore

class TodoIndentationGuideLayer: CAShapeLayer {

    var level: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    /// 深度辅助线x偏移距离
    var dx: CGFloat = 0.0 {
        didSet {
            if dx != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 缩进宽度
    var indentationWidth: CGFloat = 25.0 {
        didSet {
            if indentationWidth != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 分割线开始层级
    private let fromLevel: Int = 1
    
    override func layoutSublayers() {
        super.layoutSublayers()
        self.fillColor = UIColor.clear.cgColor
        updateLayerPath()
    }
    
    private let depthWidth = 16.0
    private let maxDepthWidth = 32.0
    
    private func updateLayerPath() {
        let toLevel = level
        guard fromLevel <= toLevel else {
            self.path = nil
            return
        }
        
        let bezierPath = UIBezierPath()
        for i in fromLevel...toLevel {
            let fromPoint = CGPoint(x: lineOffsetX(at: i), y: 0.0)
            bezierPath.move(to: fromPoint)
        
            let toPoint = CGPoint(x: fromPoint.x, y: bounds.height)
            bezierPath.addLine(to: toPoint)
        }
        
        self.path = bezierPath.cgPath
    }
    
    private func lineOffsetX(at index: Int) -> CGFloat {
        return CGFloat(index) * indentationWidth + dx
    }
}

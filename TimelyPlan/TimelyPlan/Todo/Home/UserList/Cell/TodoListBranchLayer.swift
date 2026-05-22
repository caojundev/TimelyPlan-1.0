//
//  TodoListBranchLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/9.
//

import Foundation
import UIKit
import QuartzCore

class TodoListBranchLayer: CAShapeLayer {
    
    /// 绘制层级
    var depthLineLevels: [Int]?  {
        didSet {
            setNeedsLayout()
        }
    }

    var indentationLevel: Int = 0 {
        didSet {
            setNeedsLayout()
        }
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
    
    var depthWidth = 16.0
    
    var maxDepthWidth = 32.0
    
    var maxDepth = 3
    
    /// 分割线开始层级
    private let fromLevel: Int = 1

    private let radius = 12.0
    
    override func layoutSublayers() {
        super.layoutSublayers()
        self.fillColor = UIColor.clear.cgColor
        updateLayerPath()
    }

    private func updateLayerPath() {
        let toLevel = indentationLevel
        guard fromLevel <= toLevel else {
            self.path = nil
            return
        }
  
        let halfHeight = bounds.height / 2.0
        let bezierPath = UIBezierPath()
        for i in fromLevel...toLevel {
            if containsLevel(i) {
                let fromPoint = CGPoint(x: lineOffsetX(at: i), y: 0.0)
                bezierPath.move(to: fromPoint)
                let toPoint = CGPoint(x: fromPoint.x, y: bounds.height)
                bezierPath.addLine(to: toPoint)
            }
    
            /// 绘制最后曲线
            if i == toLevel {
                let fromPoint = CGPoint(x: lineOffsetX(at: i), y: 0.0)
                bezierPath.move(to: fromPoint)
                
                let lineMiddlePoint = CGPoint(x: fromPoint.x, y: halfHeight - radius)
                bezierPath.addLine(to: lineMiddlePoint)
                
                let curveMiddlePoint = CGPoint(x: fromPoint.x + radius, y: halfHeight)
                let controlPoint = CGPoint(x: fromPoint.x, y: halfHeight)
                bezierPath.addQuadCurve(to: curveMiddlePoint, controlPoint: controlPoint)
                
                let curveEndPoint: CGPoint
                if toLevel >= maxDepth {
                    curveEndPoint = CGPoint(x: curveMiddlePoint.x + maxDepthWidth - radius, y: halfHeight)
                } else {
                    curveEndPoint = CGPoint(x: curveMiddlePoint.x + depthWidth - radius, y: halfHeight)
                }
                
                bezierPath.addLine(to: curveEndPoint)
            }
        }
        
        self.path = bezierPath.cgPath
    }
    
    private func lineOffsetX(at index: Int) -> CGFloat {
        return CGFloat(index) * indentationWidth + dx
    }
    
    private func containsLevel(_ level: Int) -> Bool {
        return depthLineLevels?.contains(level) ?? false
    }
    
}

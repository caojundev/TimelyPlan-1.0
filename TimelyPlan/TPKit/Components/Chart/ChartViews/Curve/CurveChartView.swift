//
//  CurveChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/24.
//

import Foundation
import QuartzCore
import UIKit

class CurveChartView: PointChartView {

    /// 曲线图层
    private lazy var curveLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Color(0x5856D6).cgColor
        layer.lineWidth = 3.0
        layer.lineCap = .round
        layer.lineJoin = .round
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.highlightView.margin = 5.0
        self.highlightView.startFromElement = false
        self.highlightView.endOnTop = true
        self.canvasView.layer.insertSublayer(curveLayer, below: pointsView.layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        curveLayer.frame = canvasView.bounds
        updateCurveLayerPath()
    }
    
    // MARK: - 绘制曲线
    private func updateCurveLayerPath() {
        guard pointMarks.count > 1 else {
            self.curveLayer.path = nil
            return
        }
        
        let bezierPath = UIBezierPath()
        for i in 0..<pointMarks.count {
            let currentPoint = positionForChartMark(pointMarks[i])
            if i == 0 {
                bezierPath.move(to: currentPoint)
            } else {
                let previousPoint = positionForChartMark(pointMarks[i-1])
                let x = (previousPoint.x + currentPoint.x) / 2.0
                let controlPoint1 = CGPoint(x: x, y: previousPoint.y)
                let controlPoint2 = CGPoint(x: x, y: currentPoint.y)
                bezierPath.addCurve(to: currentPoint,
                                    controlPoint1: controlPoint1,
                                    controlPoint2: controlPoint2)
            }
        }
        
        self.curveLayer.path = bezierPath.cgPath
    }
    
    private func animateCurveLayer() {
        self.curveLayer.strokeEnd = 0.0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.6
        animation.fromValue = NSNumber(value: 0.0)
        animation.toValue = NSNumber(value: 1.0)
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        self.curveLayer.add(animation, forKey: "CurveLayer")
    }
    
    
}

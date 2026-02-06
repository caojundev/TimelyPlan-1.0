//
//  FocusHourlyActivityView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/16.
//

import Foundation
import UIKit

class FocusHourlyActivityView: UIView {

    var hourlyActivity: [Int: Float]? {
        didSet {
            setNeedsLayout()
        }
    }
    
    let lineWidth: CGFloat = 4.0
    
    let lineMargin: CGFloat = 2.0
    
    /// 活动绘制图层
    private lazy var activityLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = lineWidth
        layer.strokeColor = Color(0x66D065).cgColor
        layer.lineCap = .round
        return layer
    }()
    
    /// 背景图层
    private lazy var backLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = lineWidth
        layer.strokeColor = Color(0x888888, 0.4).cgColor
        layer.lineCap = .round
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(backLayer)
        layer.addSublayer(activityLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var width = (lineWidth + lineMargin) * 24.0 + lineMargin
        width += padding.horizontalLength
        return CGSize(width: width, height: 60.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backLayer.frame = self.layoutFrame()
        activityLayer.frame = backLayer.frame
        updateBackLayer()
        updateActivityLayer()
    }
    
    private func updateActivityLayer() {
        let path = UIBezierPath()
        for hour in 0..<HOURS_PER_DAY {
            guard let progress = hourlyActivity?[hour], progress > 0 else {
                continue
            }
            
            let lineEnd = lineEnd(hour: hour, progress: progress)
            path.move(to: CGPoint(x: lineEnd.x, y: activityLayer.bounds.height))
            path.addLine(to: lineEnd)
        }
        
        activityLayer.path = path.cgPath
    }
    
    private func updateBackLayer() {
        let path = UIBezierPath()
        for hour in 0..<HOURS_PER_DAY {
            let x = originX(for: hour)
            let y = activityLayer.bounds.height
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x, y: y - 1.0))
        }
        
        backLayer.path = path.cgPath
    }
    
    private func originX(for hour: Int) -> CGFloat {
        let x = CGFloat(hour + 1) * lineMargin + CGFloat(hour) * lineWidth + lineWidth / 2.0
        return x
    }
    
    private func lineEnd(hour: Int, progress: Float) -> CGPoint {
        let layoutFrame = activityLayer.bounds
        let x = originX(for: hour)
        var h = validatedProgress(CGFloat(progress)) * layoutFrame.height
        if h > 0 && h < 1.0 {
            h = 1.0
        }
                                 
        let y = layoutFrame.height - h
        return CGPoint(x: layoutFrame.minX + x, y: layoutFrame.minY + y)
    }
}

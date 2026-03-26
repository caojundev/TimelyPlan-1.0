//
//  WatchTickView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/24.
//

import Foundation
import UIKit

class WatchTickView: UIView {
    
    var strokeEnd: CGFloat = 1.0 {
        didSet {
            tickLayer.strokeEnd = min(1.0, max(0.0, strokeEnd))
        }
    }
    
    var scaleLineWidth: CGFloat = 2.0 {
        didSet {
            tickLayer.lineWidth = scaleLineWidth
        }
    }
    
    var scaleLength: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var scaleCount: Int = 60 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var scaleColor: UIColor = UIColor.label {
        didSet {
            tickLayer.strokeColor = scaleColor.cgColor
        }
    }
    
    private var tickLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tickLayer.strokeEnd = 1.0
        tickLayer.lineCap = .round
        layer.addSublayer(tickLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tickLayer.frame = bounds
        tickLayer.lineWidth = scaleLineWidth
        tickLayer.strokeColor = scaleColor.cgColor
        updateTickLayerPath()
    }
    
    private func updateTickLayerPath() {
        let path = UIBezierPath()
        let centerX = bounds.width / 2 // 表盘中心点X坐标
        let centerY = bounds.height / 2 // 表盘中心点Y坐标
        let outerRadius = min(centerX, centerY)
        let startAngle = -CGFloat.pi / 2 // 起始角度为12点钟方向
        let endAngle = CGFloat.pi * 1.5 // 结束角度为12点钟方向
        let angleStep = (endAngle - startAngle) / CGFloat(scaleCount) // 每个刻度线之间的角度差
        
        for i in 0..<scaleCount {
            let scaleLength = scaleLength(at: i) ?? scaleLength
            let radius = outerRadius - scaleLength // 刻度线的长度
            let angle = startAngle + CGFloat(i) * angleStep // 当前刻度线的角度
            let startX = centerX + cos(angle) * (radius + scaleLength) // 刻度线起始点X坐标
            let startY = centerY + sin(angle) * (radius + scaleLength) // 刻度线起始点Y坐标
            let endX = centerX + cos(angle) * radius // 刻度线结束点X坐标
            let endY = centerY + sin(angle) * radius // 刻度线结束点Y坐标
        
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        
        self.tickLayer.path = path.cgPath
    }
    
    func commitStrokeAnimation() {
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.values = [0, 1.0]
        strokeEndAnimation.duration = 0.6
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        tickLayer.add(strokeEndAnimation, forKey: "strokeEndAnimation")
    }

    /// 子类重写可自定义刻度长度
    func scaleLength(at index: Int) -> CGFloat? {
        return nil
    }
    
}

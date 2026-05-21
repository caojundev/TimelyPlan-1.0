//
//  CalendarTimelineDotIndicator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/20.
//

import Foundation
import UIKit

class CalendarTimelineDotIndicator: UIView {
    
    private lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.redPrimary.cgColor
        layer.fillColor = layer.strokeColor
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        self.padding = UIEdgeInsets(horizontal: 2.0)
        self.isUserInteractionEnabled = false
        layer.addSublayer(shapeLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            self.shapeLayer.frame = bounds
        }
        
        updateLayerPath()
    }
    
    private func updateLayerPath() {
        let dotSize: CGSize = .size(1)
        let layoutFrame = layoutFrame()
        let bezierPath = UIBezierPath()
        let dotCenter = CGPoint(x: layoutFrame.minX + dotSize.halfWidth, y: layoutFrame.midY)
        bezierPath.addArc(withCenter: dotCenter,
                          radius: dotSize.halfWidth,
                          startAngle: radians(of: 0.0),
                          endAngle: radians(of: 360.0),
                          clockwise: true)
        bezierPath.move(to: dotCenter)
        bezierPath.addLine(to: CGPoint(x: layoutFrame.maxX, y: layoutFrame.midY))
        self.shapeLayer.path = bezierPath.cgPath
    }
}

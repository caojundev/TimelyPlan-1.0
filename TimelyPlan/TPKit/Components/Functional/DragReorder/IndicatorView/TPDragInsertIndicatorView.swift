//
//  TPDragInsertIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/25.
//

import Foundation
import UIKit

class TPDragInsertIndicatorView: UIView {

    /// 缩进宽度
    var indentationWidth: CGFloat = 20.0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 缩进层级
    var indentationLevel: Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 线条粗细
    var lineWidth: CGFloat = 2.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var lineColor: UIColor = Color(0x046BDE) {
        didSet {
            indicatorLayer.strokeColor = lineColor.cgColor
        }
    }
    
    var backColor: UIColor = Color(0xFFFFFF, 0.8) {
        didSet {
            backLayer.strokeColor = backColor.cgColor
        }
    }
    
    private lazy var indicatorLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = lineColor.cgColor
        layer.lineCap = .round
        return layer
    }()
    
    private lazy var backLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = backColor.cgColor
        layer.lineCap = .round
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.layer.addSublayer(backLayer)
        self.layer.addSublayer(indicatorLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backLayer.frame = self.bounds
        self.indicatorLayer.frame = self.bounds
        self.backLayer.lineWidth = lineWidth + 2.0
        self.indicatorLayer.lineWidth = lineWidth
        self.updateLayerPath()
    }
    
    private func updateLayerPath() {
        let radius = self.lineWidth
        let arcCenter = CGPoint(x: CGFloat(indentationLevel) * indentationWidth + radius, y: bounds.midY)
        let path = UIBezierPath(arcCenter: arcCenter,
                                radius: radius,
                                startAngle: 0,
                                endAngle: CGFloat(2 * Double.pi),
                                clockwise: true)
        path.move(to: CGPoint(x: arcCenter.x + radius, y: arcCenter.y))
        path.addLine(to: CGPoint(x: bounds.width, y: arcCenter.y))
        self.indicatorLayer.path = path.cgPath
        self.backLayer.path = path.cgPath
    }
}

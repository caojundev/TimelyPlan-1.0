//
//  TPCircularCheckbox.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/17.
//

import UIKit

class TPCircularCheckbox: TPBaseButton {
    
    private var outerLayer: CAShapeLayer!
    private var innerLayer: CAShapeLayer!
        
    var outerLineWidth: CGFloat = 2.0 {
        didSet {
            outerLayer.lineWidth = outerLineWidth
            setNeedsLayout()
        }
    }
        
    var innerMargin: CGFloat = 1.6 {
        didSet {
            setNeedsLayout()
        }
    }
        
    var outerColor: UIColor = .primary {
        didSet {
            setNeedsLayout()
        }
    }
        
    var innerColor: UIColor = .primary {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        outerLayer = CAShapeLayer()
        outerLayer.lineWidth = outerLineWidth
        outerLayer.fillColor = UIColor.clear.cgColor
        outerLayer.strokeColor = outerColor.cgColor
        self.contentView.layer.addSublayer(outerLayer)
        
        innerLayer = CAShapeLayer()
        innerLayer.strokeColor = UIColor.clear.cgColor
        innerLayer.fillColor = innerColor.cgColor
        self.contentView.layer.addSublayer(innerLayer)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 20.0, height: 20.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        innerLayer.setAffineTransform(.identity)
        innerLayer.frame = bounds
        innerLayer.fillColor = innerColor.cgColor
        
        outerLayer.frame = bounds
        outerLayer.strokeColor = outerColor.cgColor
        
        updateLayerPath()
        updateInnerLayerAnimated(false)
    }
    
    private func updateLayerPath() {
        let center = bounds.middlePoint
        let d = min(bounds.width, bounds.height)
        
        let outerRadius = d / 2.0 - outerLineWidth / 2.0
        outerLayer.path = UIBezierPath(arcCenter: center, radius: outerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        
        let innerRadius = outerRadius - outerLineWidth / 2.0 - innerMargin
        innerLayer.path = UIBezierPath(arcCenter: center, radius: innerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
    }
    
    private func updateInnerLayerAnimated(_ animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        let scale: CGFloat = isChecked ? 1.0 : 0.0
        innerLayer.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
        CATransaction.commit()
    }

    // MARK: - Checkable
    override func setChecked(_ isChecked: Bool, animated: Bool = false) {
        super.setChecked(isChecked, animated: animated)
        updateInnerLayerAnimated(animated)
    }
}

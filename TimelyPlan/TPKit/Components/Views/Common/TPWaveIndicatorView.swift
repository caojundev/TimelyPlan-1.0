//
//  TPWaveIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/19.
//

import Foundation
import UIKit

class TPWaveIndicatorView: UIView {
    
    var lineWidth: CGFloat = 2.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var lineHeight: CGFloat = 16.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var lineMargin: CGFloat = 2.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var lineColor: UIColor = .primary {
        didSet {
            lineLayer.backgroundColor = lineColor.cgColor
        }
    }
    
    private let lineCount: Int = 3
    
    private let lineLayer = CALayer()
    
    private let replicatorLayer = CAReplicatorLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        lineLayer.masksToBounds = true
        lineLayer.backgroundColor = lineColor.cgColor
        lineLayer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        replicatorLayer.instanceCount = lineCount
        replicatorLayer.instanceDelay = 0.15
        replicatorLayer.addSublayer(lineLayer)
        layer.addSublayer(replicatorLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let lineX = (bounds.width - CGFloat(lineCount) * lineWidth - CGFloat(lineCount - 1) * lineMargin) / 2.0
        let lineY = (bounds.height - lineHeight) / 2.0
        lineLayer.frame = CGRect.init(x: lineX, y: lineY, width: lineWidth, height: lineHeight)
        lineLayer.backgroundColor = lineColor.cgColor
        lineLayer.cornerRadius = lineWidth / 2.0
        
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(lineWidth + lineMargin, 0, 0)
        replicatorLayer.frame = bounds
    }
    
    fileprivate func scaleYAnimation() -> CABasicAnimation{
        let anim = CABasicAnimation.init(keyPath: "transform.scale.y")
        anim.toValue = 0.1
        anim.duration = 0.4
        anim.autoreverses = true
        anim.repeatCount = .infinity
        return anim
    }
    
    func startAnimation() {
        lineLayer.removeAllAnimations()
        lineLayer.add(scaleYAnimation(), forKey: "scaleAnimation")
    }
    
    func stopAnimation() {
        lineLayer.removeAllAnimations()
    }
}

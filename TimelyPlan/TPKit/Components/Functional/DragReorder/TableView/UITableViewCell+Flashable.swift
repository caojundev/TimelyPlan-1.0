//
//  Flashable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/28.
//


import Foundation
import UIKit

/// 聚焦动画
protocol Flashable {
    
    /// 执行闪烁动画
    func startFlashing()
    
    /// 停止闪烁动画
    func stopFlashing()
}

private struct FlashingKey {
    static var layer = "flashingLayer"
    static var animation = "flashingAnimation"
}

extension UITableViewCell: Flashable {
    
    /// 闪烁动画图层
    private var flashingLayer: CALayer? {
        get {
            
            return objc_getAssociatedObject(self, &FlashingKey.layer) as? CALayer
        }
        
        set {
            objc_setAssociatedObject(self, &FlashingKey.layer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
      
    /// 闪烁动画
    private var flashingAnimation: CAAnimation? {
        get {
            return objc_getAssociatedObject(self, &FlashingKey.animation) as? CAAnimation
        }

        set {
            objc_setAssociatedObject(self, &FlashingKey.animation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func stopFlashing() {
        flashingLayer?.removeAllAnimations()
        flashingLayer?.removeFromSuperlayer()
        flashingLayer = nil
    }
    
    func startFlashing() {
        self.stopFlashing()
        let animateLayer = CALayer()
        animateLayer.opacity = 0.0
        animateLayer.frame = bounds
        animateLayer.backgroundColor = selectedBackgroundView?.backgroundColor?.cgColor
        layer.addSublayer(animateLayer)
        self.flashingLayer = animateLayer
        
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.delegate = self
        animation.duration = 0.8
        animation.values = [0, 0.5, 1.0, 1.0, 1.0, 0.5, 0, 0.5, 1.0, 1.0, 1.0, 0.5, 0]
        focusAnimation = animation
        animateLayer.add(animation, forKey: "Opacity")
    }
    
    // MARK: - CAAnimationDelegate
    public override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let flashingLayer = flashingLayer, anim == focusAnimation {
            flashingLayer.removeFromSuperlayer()
            self.flashingLayer = nil
            self.flashingAnimation = nil
        }
    }
}


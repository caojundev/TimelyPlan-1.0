//
//  FocusAnimatable.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/7.
//

import Foundation
import UIKit

/// 聚焦动画
protocol FocusAnimatable {
    
    /// 圆角半径
    var focusCornerRadius: CGFloat { get }
    
    /// 内间距
    var focusPadding: UIEdgeInsets { get }
    
    /// 线条宽度
    var focusLineWidth: CGFloat { get }
    
    /// 线条颜色
    var focusLineColor: UIColor { get }
    
    /// 执行聚焦动画
    func commitFocusAnimation()
    
    /// 移除聚焦动画
    func removeFocusAnimation()
}

extension FocusAnimatable {
    
    /// 圆角半径
    var focusCornerRadius: CGFloat {
        return 12.0
    }
    
    /// 线条宽度
    var focusLineWidth: CGFloat {
        return 2.5
    }
    
    var focusPadding: UIEdgeInsets {
        return UIEdgeInsets(value: 0.0)
    }
    
    /// 线条颜色
    var focusLineColor: UIColor {
        return Color(0x007AFF)
    }
    
    /// 线条颜色
    var focusCoverColor: UIColor? {
        let lineColor = focusLineColor
        return lineColor.withAlphaComponent(0.1)
    }
}


private struct AssociatedKeys {
    static var focusAnimateLayer = "focusAnimateLayer"
    static var focusAnimation = "focusAnimation"
}

extension UIView: CAAnimationDelegate {
    
    /// 聚焦动画图层
    var focusAnimateLayer: CALayer? {
        get {
            
            return objc_getAssociatedObject(self, &AssociatedKeys.focusAnimateLayer) as? CALayer
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.focusAnimateLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
      
    /// 聚焦动画
    var focusAnimation: CAAnimation? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.focusAnimation) as? CAAnimation
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKeys.focusAnimation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func removeFocusAnimation() {
        if let animateLayer = focusAnimateLayer{
            animateLayer.removeAllAnimations()
            animateLayer.removeFromSuperlayer()
            focusAnimateLayer = nil
        }
    }
    
    /// 执行聚焦动画
    func commitFocusAnimation() {
        guard let object = self as? FocusAnimatable else {
            return
        }
        
        if let animateLayer = focusAnimateLayer{
            animateLayer.removeAllAnimations()
            animateLayer.removeFromSuperlayer()
        }

        let animateLayer = animateLayer(cornerRadius: object.focusCornerRadius,
                                        padding: object.focusPadding,
                                        lineWidth: object.focusLineWidth,
                                        lineColor: object.focusLineColor,
                                        coverColor: object.focusCoverColor)
        focusAnimateLayer = animateLayer
        layer.addSublayer(animateLayer)
        
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.delegate = self
        animation.duration = 1.5
        animation.values = [0, 0.5, 1.0, 1.0, 1.0, 0.5, 0, 0.5, 1.0, 1.0, 1.0, 0.5, 0]
        focusAnimation = animation
        animateLayer.add(animation, forKey: "Opacity")
    }

    private func animateLayer(cornerRadius: CGFloat,
                              padding: UIEdgeInsets,
                              lineWidth: CGFloat,
                              lineColor: UIColor,
                              coverColor: UIColor? = nil) -> CALayer {
        let layer = CAShapeLayer()
        layer.frame = bounds
    
        let roundedRect = bounds.inset(by: padding)
        let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        layer.path = path.cgPath
        layer.lineWidth = lineWidth
        layer.strokeColor = lineColor.cgColor
        
        if let coverColor = coverColor {
            layer.fillColor = coverColor.cgColor
        } else {
            layer.fillColor = UIColor.clear.cgColor
        }
        
        layer.backgroundColor = UIColor.clear.cgColor
        layer.opacity = 0.0
        return layer
    }
    
    // MARK: - CAAnimationDelegate
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animateLayer = focusAnimateLayer, anim == focusAnimation {
            animateLayer.removeFromSuperlayer()
            focusAnimateLayer = nil
            focusAnimation = nil
        }
    }
}

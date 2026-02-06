//
//  CAAnimationGroup+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/20.
//

import Foundation
import QuartzCore

extension CAAnimationGroup {

    static func group(withDuration duration: TimeInterval,
                      fromScale: CGFloat,
                      toScale: CGFloat,
                      fromOpacity: CGFloat,
                      toOpacity: CGFloat) -> CAAnimationGroup {
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        
        let scaleAnimation = CAKeyframeAnimation()
        scaleAnimation.keyPath = "transform.scale"
        scaleAnimation.values = [fromScale, toScale]
        scaleAnimation.calculationMode = .cubic
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = fromOpacity
        opacityAnimation.toValue = toOpacity
        
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        return animationGroup
    }
    
    static func scaleOpacityAnimationGroup(withDuration duration: TimeInterval) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        
        let scaleAnimation = CAKeyframeAnimation()
        scaleAnimation.keyPath = "transform.scale"
        scaleAnimation.values = [1.0, 0.85, 1.2, 0.95, 1.05, 1.0]
        scaleAnimation.calculationMode = .cubic
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        return animationGroup
    }
    
}

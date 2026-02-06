//
//  CAKeyframeAnimation+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/20.
//

import Foundation
import QuartzCore

extension CAKeyframeAnimation {
    
    /// 缩放动画
    static func scaleKeyframeAnimation(withDuration duration: TimeInterval) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [1.0, 0.85, 1.2, 0.95, 1.05, 1.0]
        animation.duration = duration
        animation.calculationMode = .cubic
        return animation
    }
}

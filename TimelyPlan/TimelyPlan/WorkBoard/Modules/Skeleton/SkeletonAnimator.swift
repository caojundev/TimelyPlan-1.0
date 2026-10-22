//
//  SkeletonAnimator.swift
//  Skeleton
//
//  只负责「上色 + 动画」。所有骨架共享同一个时间基准，保证同屏多个骨架的
//  高光是同步扫过的，不会一行快一行慢。
//

import UIKit

enum SkeletonAnimator {

    private enum Key {
        static let shimmer = "sk.shimmer"
        static let pulse = "sk.pulse"
    }

    /// 全局时间基准。以它作为 beginTime，重复动画会在同一相位上运行
    private static let referenceTime = CACurrentMediaTime()

    static func apply(to layer: CAGradientLayer,
                      config: SkeletonConfig,
                      animation: SkeletonConfig.Animation,
                      traits: UITraitCollection) {

        layer.removeAnimation(forKey: Key.shimmer)
        layer.removeAnimation(forKey: Key.pulse)
        layer.opacity = 1

        let base = config.baseColor.resolvedColor(with: traits)
        let highlight = config.highlightColor.resolvedColor(with: traits)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        switch animation {
        case .shimmer:
            layer.colors = [base.cgColor, highlight.cgColor, base.cgColor] as [Any]
            layer.locations = [0, 0.5, 1]
        case .none, .pulse:
            layer.colors = [base.cgColor, base.cgColor] as [Any]
            layer.locations = [0, 1]
        }
        CATransaction.commit()

        switch animation {
        case .none:
            break

        case .shimmer(let duration):
            // 用 locations 做扫光：与 layer 尺寸无关，改 frame 也不用重启动画
            let sweep = CABasicAnimation(keyPath: "locations")
            sweep.fromValue = [-0.4, -0.2, 0.0].map { NSNumber(value: $0) }
            sweep.toValue = [1.0, 1.2, 1.4].map { NSNumber(value: $0) }
            sweep.duration = max(duration, 0.1)
            sweep.repeatCount = .infinity
            sweep.timingFunction = CAMediaTimingFunction(name: .linear)
            sweep.beginTime = referenceTime
            layer.add(sweep, forKey: Key.shimmer)

        case .pulse(let duration):
            let breath = CABasicAnimation(keyPath: "opacity")
            breath.fromValue = 1.0
            breath.toValue = 0.45
            breath.duration = max(duration, 0.1) / 2
            breath.autoreverses = true
            breath.repeatCount = .infinity
            breath.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            breath.beginTime = referenceTime
            layer.add(breath, forKey: Key.pulse)
        }
    }
}

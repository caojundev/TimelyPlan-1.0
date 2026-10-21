//
//  TPShimmerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/23.
//

import Foundation
import UIKit

class TPShimmerView: UIView {
    private let gradientLayer = CAGradientLayer()
    private var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.clear
    
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        
        // 调整颜色分布位置，让过渡更加平滑
        gradientLayer.locations = [0.0, 0.35, 0.5, 0.65, 1.0]
        
        gradientLayer.startPoint = CGPoint(x: 0.1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 0.5)
        
        self.layer.addSublayer(gradientLayer)
        self.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        if !isAnimating {
            startAnimating()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil && !isAnimating {
            setNeedsLayout()
        }
    }
    
    private func startAnimating() {
        guard !isAnimating else { return }
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 2.0
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        // 使用 CAMediaTimingFunction 设置非线性动画（贝塞尔曲线）
        // 参数：controlPoint1 和 controlPoint2 定义缓动曲线
        // 这里使用 ease-in-out 效果，让动画开始和结束都更平滑
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        
        gradientLayer.add(animation, forKey: "skeletonAnimation")
        isAnimating = true
    }
    
    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: "skeletonAnimation")
        isAnimating = false
    }
}

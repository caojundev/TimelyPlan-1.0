//
//  TPFireworkLayer.swift
//  FireworkLayer
//
//  Created by caojun on 2022/5/5.
//

import QuartzCore
import UIKit

private let kDotRadius: CGFloat = 4.0

class TPFireworkLayer: CALayer, CAAnimationDelegate {
    
    // MARK: - Properties
    
    /// 半径
    var radius: CGFloat = 18.0
    
    /// 彩色圆点图层
    private var dotLayers: [CALayer] = []
    
    /// 动画结束回调
    var completion: ((Bool) -> Void)?
    
    // MARK: - Public Methods
    
    /// 在特定视图上显示烟花动画
    class func showOnView(_ view: UIView,
                         radius: CGFloat,
                         completion: ((Bool) -> Void)? = nil) {
        let adjustedRadius = radius + kDotRadius / 2.0
        
        let fireworkLayer = TPFireworkLayer()
        fireworkLayer.radius = adjustedRadius
        fireworkLayer.cornerRadius = adjustedRadius
        fireworkLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        fireworkLayer.completion = completion
        
        view.layer.addSublayer(fireworkLayer)
        fireworkLayer.animate()
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupDotLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDotLayers()
    }
    
    private func setupDotLayers() {
        radius = 18.0
        
        let colors: [UIColor] = [
            Color(0xDF5626),
            Color(0xFEB75F),
            Color(0x27B86F),
            Color(0x258ADC),
            Color(0x854DCD),
            Color(0xFF009E)
        ]
        
        let shuffledColors = colors.shuffled()
        
        var layers: [CALayer] = []
        for color in shuffledColors {
            let layer = CALayer()
            layer.opacity = 0
            layer.backgroundColor = color.cgColor
            addSublayer(layer)
            layers.append(layer)
        }
        
        dotLayers = layers
    }
    
    // MARK: - Animation
    
    private func animate() {
        let center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        
        let startAngleDegrees = CGFloat.random(in: 0..<360)
        var endAngleDegrees = startAngleDegrees
        
        for dotLayer in dotLayers {
            dotLayer.frame = CGRect(x: 0, y: 0, width: 2 * kDotRadius, height: 2 * kDotRadius)
            dotLayer.position = CGPoint(x: center.x, y: center.y - radius)
            dotLayer.cornerRadius = kDotRadius
            dotLayer.opacity = 1.0
            
            endAngleDegrees += 60.0
            
            let bezierPath = UIBezierPath()
            bezierPath.addArc(withCenter: center,
                            radius: radius,
                        startAngle: degreesToRadians(startAngleDegrees),
                          endAngle: degreesToRadians(endAngleDegrees),
                         clockwise: true)
            
            // 位置动画
            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            positionAnimation.duration = 0.5
            positionAnimation.path = bezierPath.cgPath
            positionAnimation.calculationMode = .paced
            positionAnimation.isRemovedOnCompletion = false
            positionAnimation.fillMode = .forwards
            positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // 缩放动画
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = 0.5
            scaleAnimation.toValue = 0
            scaleAnimation.beginTime = 0.4
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = .forwards
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // 动画组
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 1.0
            animationGroup.isRemovedOnCompletion = false
            animationGroup.fillMode = .forwards
            animationGroup.animations = [positionAnimation, scaleAnimation]
            animationGroup.delegate = self
            
            dotLayer.add(animationGroup, forKey: "Animation")
        }
    }
    
    // MARK: - CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if superlayer != nil {
            for dotLayer in dotLayers {
                dotLayer.removeAllAnimations()
                dotLayer.removeFromSuperlayer()
            }
            
            completion?(true)
            removeFromSuperlayer()
        } else {
            completion?(false)
        }
    }
}

//
//  TPCircleOutlineProgressView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation
import UIKit

class TPCircleOutlineProgressView: UIView {
    
    let kDefaultLineWidth = 4.0
    
    let kStartStrokeEnd = -1.0 / 360.0

    /// 进度圆环半径
    var radius: CGFloat = 60.0

    var strokeStart: CGFloat = 0.0
    
    /// 进度（范围：0～1）
    private var _progress: CGFloat = 0.0
    var progress: CGFloat {
        get {
            return _progress
        }
        
        set {
            setProgress(newValue, animated: false)
        }
    }

    /// 背景圆环线条宽度
    var backLineWidth: CGFloat = 0.0 {
        didSet {
            self.borderLayer.lineWidth = backLineWidth
        }
    }
    
    /// 背景圆环线条颜色
    var backLineColor: UIColor? = Color(0x000000, 0.2) {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 进度圆环线条宽度
    var progressLineWidth: CGFloat = 0.0 {
        didSet {
            self.progressLayer.lineWidth = progressLineWidth
        }
    }
    
    /// 进度圆环线条颜色
    var progressLineColor: UIColor? = .primary {
        didSet {
            setNeedsLayout()
        }
    }
    
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineWidth = kDefaultLineWidth
        return layer
    }()
    
    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = kDefaultLineWidth
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(self.borderLayer)
        self.layer.addSublayer(self.progressLayer)
        self.progressLayer.strokeEnd = kStartStrokeEnd
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.radius = min(self.bounds.width, self.bounds.height) / 2.0
        self.borderLayer.frame = self.bounds
        self.progressLayer.frame = self.bounds
        self.updateBorderLayerPath()
        self.updateProgressLayer()
        self.borderLayer.strokeColor = backLineColor?.cgColor
        self.progressLayer.strokeColor = progressLineColor?.cgColor
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = 2 * radius + progressLineWidth / 2.0
        return CGSize(value: width)
    }
    
    // MARK: - Update Layer Path
    func updateBorderLayerPath() {
        let path = UIBezierPath()
        path.addArc(withCenter: borderLayer.position,
                    radius: radius - progressLineWidth / 2.0,
                    startAngle: 0,
                    endAngle: radians(of: 360.0),
                    clockwise: true)
        borderLayer.path = path.cgPath
    }

    /// 更新进度图层路径
    func updateProgressLayer() {
        let startAngle = -CGFloat.pi / 2.0
        let endAngle = startAngle + 2.0 * CGFloat.pi

        let path = UIBezierPath()
        path.addArc(withCenter: progressLayer.position,
                   radius: radius - progressLineWidth / 2.0,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: true)
        progressLayer.path = path.cgPath
    }
    
    /// 设置进度并可选择动画
    // Set and animate the progress value
    func setProgress(_ progress: CGFloat, animated: Bool) {
       if _progress == progress {
           return
       }

       let toProgress = max(0.0, min(1.0, progress))
       _progress = toProgress
       let strokeEnd = (toProgress == 0.0) ? kStartStrokeEnd : toProgress

       if animated {
           var fromStrokeStart = progressLayer.strokeStart
           var fromStrokeEnd = progressLayer.strokeEnd
           let previousAnimation = progressLayer.animation(forKey: Self.kProgressAnimationKey)
           if previousAnimation != nil {
               if let presentationLayer = progressLayer.presentation() {
                   fromStrokeStart = presentationLayer.strokeStart
                   fromStrokeEnd = presentationLayer.strokeEnd
                   updateProgress(strokeStart: fromStrokeStart, strokeEnd: fromStrokeEnd)
               }
           }
           
           /// 计算动画时间
           var duration = abs(toProgress - fromStrokeEnd) * 2.0
           duration = max(min(0.8, duration), 0.4)

           /// 添加动画
           let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
           strokeStartAnimation.fromValue = fromStrokeStart
           strokeStartAnimation.toValue = strokeStart

           let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
           strokeEndAnimation.fromValue = fromStrokeEnd
           strokeEndAnimation.toValue = strokeEnd

           let group = CAAnimationGroup()
           group.delegate = self
           group.duration = duration
           group.isRemovedOnCompletion = false
           group.fillMode = .forwards
           group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
           group.animations = [strokeStartAnimation, strokeEndAnimation]
           progressLayer.add(group, forKey: Self.kProgressAnimationKey)
       } else {
           CATransaction.begin()
           CATransaction.setDisableActions(true)
           progressLayer.strokeStart = strokeStart
           progressLayer.strokeEnd = strokeEnd
           CATransaction.commit()
       }
    }
    
    // MARK: - CAAnimationDelegate
    static let kProgressAnimationKey = "ProgressAnimation"
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let currentAnimation = progressLayer.animation(forKey: Self.kProgressAnimationKey), currentAnimation == anim {
            updateProgress(strokeStart: strokeStart, strokeEnd: _progress)
        }
    }
    
    func updateProgress(strokeStart: CGFloat, strokeEnd: CGFloat) {
        /// 设置进度动画结束后移除所有动画
        progressLayer.removeAllAnimations()
          
        /// 设置strokeEnd属性
          CATransaction.begin()
          CATransaction.setDisableActions(true)
          progressLayer.strokeStart = strokeStart
          progressLayer.strokeEnd = strokeEnd
          CATransaction.commit()
      }
}

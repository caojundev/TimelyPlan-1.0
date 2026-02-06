//
//  PomodoroFragmentLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/16.
//

import Foundation

struct PomodoroFragment {
    
    /// 开始进度
    var fromProgress: CGFloat = 0

    /// 结束进度
    var toProgress: CGFloat = 0
}


class PomodoroFragmentLayer: CAShapeLayer {
    
    /// 分段数组
    var fragments: [PomodoroFragment] = [] {
        didSet {
            updatePath()
        }
    }
    
    private var fromAngle: CGFloat = -90.0
    private var toAngle: CGFloat = 270.0
    private var radius: CGFloat = 0
    
    override init(layer: Any) {
        super.init(layer: layer)
        fillColor = UIColor.clear.cgColor
    }
    
    override init() {
       super.init()
       fillColor = UIColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers() {
       super.layoutSublayers()
       radius = bounds.width / 2.0 - lineWidth / 2.0
       updatePath()
    }

    private func bezierPath(for fragments: [PomodoroFragment]) -> UIBezierPath {
        let center = self.bounds.middlePoint
        let path = UIBezierPath()
        for fragment in fragments {
            let point = pointAtCircleOfProgress(fragment.fromProgress)
            let startDegree = endAngleOfProgress(fragment.fromProgress)
            let endDegree = endAngleOfProgress(fragment.toProgress)
            path.move(to: point)
            path.addArc(withCenter: center,
                        radius: radius,
                        startAngle: radians(of: startDegree),
                        endAngle: radians(of: endDegree),
                        clockwise: true)
       }
        
       return path
    }

    private func updatePath() {
       updatePathAnimated(false)
    }

    func updatePathAnimated(_ animated: Bool) {
       let endPath = bezierPath(for: fragments)
       path = endPath.cgPath

       if animated {
           let strokeStartAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
           strokeStartAnimation.values = [1.0, 0]
           strokeStartAnimation.duration = 0.6
           strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
           add(strokeStartAnimation, forKey: "LayerPathAnimation")
       }
    }

    private func endAngleOfProgress(_ progress: CGFloat) -> CGFloat {
       var endAngle = fromAngle
       endAngle += progress * (toAngle - fromAngle)
       return endAngle
    }

    private func pointAtCircleOfProgress(_ progress: CGFloat) -> CGPoint {
       let endAngle = endAngleOfProgress(progress)
        let point = pointAtCircle(center: bounds.middlePoint,
                                  radius: radius,
                                  angle: endAngle)
       return point
    }
}

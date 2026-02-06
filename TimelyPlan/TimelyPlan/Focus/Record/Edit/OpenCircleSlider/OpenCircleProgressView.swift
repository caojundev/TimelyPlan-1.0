//
//  OpenCircleScoreView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/27.
//

import Foundation
import UIKit

class OpenCircleProgressView: UIView, UIGestureRecognizerDelegate {

    var fromValue: CGFloat = 0
    
    var toValue: CGFloat = 100
 
    private(set) var fromAngle: CGFloat = -230
    
    private(set) var toAngle: CGFloat = 50

    private(set) var lineWidth: CGFloat = 36
    
    lazy var progressMaskLayer: CAShapeLayer = {
        var layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = .round
        layer.strokeColor = UIColor.black.cgColor
        layer.strokeStart = 0
        return layer
    }()
    
    private let gradientImage = resGetImage("OpenCircleAngleGradient")
    lazy var progressView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = gradientImage
        return imageView
    }()
    
    lazy var backMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = .round
        layer.strokeColor = UIColor.black.cgColor
        return layer
    }()
    
    lazy var backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.2
        imageView.contentMode = .scaleAspectFill
        imageView.image = gradientImage
        return imageView
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        label.textAlignment = .center
        label.textColor = UIColor(white: 1.0, alpha: 0.8)
        return label
    }()
    
    lazy var indicatorView: UIView = {
        let indicatorWidth = lineWidth - 4.0
        let frame = CGRect(x: 0, y: 0, width: indicatorWidth, height: indicatorWidth)
        let view = UIView(frame: frame)
        view.layer.backgroundColor = UIColor.black.cgColor
        view.layer.cornerRadius = indicatorWidth / 2.0
        view.alpha = 0.85
        return view
    }()
    
    var circleRadius: CGFloat = 0
    var circleCenter: CGPoint = .zero
    var circleBeginPoint: CGPoint = .zero
    var circleEndPoint: CGPoint = .zero
    var processPan: Bool = false
    var interaction: Bool = false

    var currentAreaIndex: Int?
    var progress: CGFloat = 0.0
    
    /// 动画定时器
    private var displayLink: CADisplayLink?
    
    private var previousValue: Int?
    var valueChanged: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMultipleTouchEnabled = false

        progressView.layer.mask = progressMaskLayer
        addSubview(progressView)
        
        backImageView.layer.mask = backMaskLayer
        addSubview(backImageView)
        
        indicatorView.addSubview(valueLabel)
        addSubview(indicatorView)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleRadius = halfWidth - lineWidth / 2.0
        circleCenter = bounds.middlePoint
        
        backImageView.frame = bounds
        progressView.frame = backImageView.frame
        
        updateMaskLayerPath()
        updateProgress()
        valueLabel.frame = indicatorView.bounds
    }
    
    private func updateMaskLayerPath() {
        circleBeginPoint = pointAtCircle(center: circleCenter,
                                         radius: circleRadius,
                                         angle: fromAngle)
        
        circleEndPoint = pointAtCircle(center: circleCenter,
                                       radius: circleRadius,
                                       angle: toAngle)
        
        let path = UIBezierPath(arcCenter: circleCenter,
                                radius: circleRadius,
                                startAngle: radians(of: fromAngle),
                                endAngle: radians(of: toAngle),
                                clockwise: true)
        progressMaskLayer.path = path.cgPath
        backMaskLayer.path = path.cgPath
    }

    // MARK: - 手势操作
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            if isPointOnIndicator(point: location){
                processPan = true
                currentAreaIndex = areaIndexOfPoint(point: location)
            }
        case .changed:
            if processPan && isPointOnCircle(point: location) {
                let areaIndex = areaIndexOfPoint(point: location)
                if let areaIndex = areaIndex, (areaIndex == currentAreaIndex ||
                                               areaIndex + 1 == currentAreaIndex ||
                                               areaIndex - 1 == currentAreaIndex) {
                    currentAreaIndex = areaIndex
                    updateProgressWithTouchPoint(point: location, animated: false)
                }
            }
            
        default:
            processPan = false
            currentAreaIndex = nil
        }
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if processPan {
            return
        }
        
        let location = gesture.location(in: self)
        if isPointOnCircle(point: location) {
            TPImpactFeedback.impactWithSoftStyle()
            updateProgressWithTouchPoint(point: location, animated: true)
        }
    }
    
    private func areaIndexOfPoint(point: CGPoint) -> Int? {
        var index: Int?
        if point.x < circleCenter.x {
            if point.y >= circleCenter.y {
                index = 1 // 左下
            } else {
                index = 2 // 左上
            }
        } else {
            if point.y >= circleCenter.y {
                index = 4 // 右上
            } else {
                index = 3 // 右下
            }
        }
        
        return index
    }

    private func isPointOnIndicator(point: CGPoint) -> Bool {
        let dx = -lineWidth / 2.0
        var rect = indicatorView.frame
        rect = rect.insetBy(dx: dx, dy: dx)
        return rect.contains(point)
    }
    
    private func isPointOnCircle(point: CGPoint) -> Bool {
        let distance = distanceBetweenPointA(pointA: point, pointB: circleCenter)
        if distance < circleRadius - lineWidth * 1.5 ||
           distance > circleRadius + lineWidth * 1.5 {
            return false
        }
        
        return true
    }
    
    private func updateProgressWithTouchPoint(point: CGPoint, animated: Bool) {
        let touchCirclePoint = pointAtCircle(center: circleCenter,
                                            radius: circleRadius,
                                             passPoint: point)
        var angle = angleWithRadius(radius: circleRadius,
                                    center: circleCenter,
                                    startCenter: circleBeginPoint,
                                    endCenter: touchCirclePoint)
        let maxAngle = toAngle - fromAngle
        if angle > maxAngle {
            if angle > maxAngle + (360 - maxAngle) / 2 {
                angle = 0
            } else {
                angle = maxAngle
            }
        }
        
        var toProgress = 100.0 * angle / (toAngle - fromAngle)
        toProgress = min(max(0.0, toProgress), 100.0)
        updateWithProgress(progress: toProgress, animated: animated)
    }

    private func updateProgress() {
        updateWithProgress(progress: progress, animated: false)
    }

    private func updateWithProgress(progress: CGFloat, animated: Bool) {
        self.progress = progress
        
        CATransaction.begin()
        if !animated {
            CATransaction.setDisableActions(true)
            indicatorView.center = pointAtCircleOfPogress(progress: progress)
        } else {
            startDisplayLink()
            CATransaction.setAnimationDuration(0.4)
        }
        
        progressMaskLayer.strokeEnd = strokeEndOfProgress(progress: progress)
        CATransaction.commit()
        
        let value = Int(currentValue)
        valueLabel.text = "\(value)"
        
        if previousValue != value {
            previousValue = value
            valueChanged?(value)
        }
    }

    private func strokeEndOfProgress(progress: CGFloat) -> CGFloat {
        var val = progress / 100.0
        if val == 0 {
            val = 0.001
        }
        
        return val
    }

    private var currentValue: CGFloat {
        let dValue = toValue - fromValue
        return fromValue + (progress / 100.0) * dValue
    }

    private func progressForValue(_ value: CGFloat) -> CGFloat {
        let progress = 100.0 * (value - fromValue) / (toValue - fromValue)
        return progress
    }
    
    
    // MARK: - Display Link
    private func startDisplayLink() {
        if displayLink != nil {
            return
        }
     
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(displayLinkAction))
        displayLink?.add(to: .current, forMode: .common)
    }

    private func stopDisplayLink() {
        if let displayLink = displayLink {
            displayLink.invalidate()
        }
        
        self.displayLink = nil
    }

    @objc private func displayLinkAction() {
        let presentationLayer = progressMaskLayer.presentation()
        let strokeEnd = presentationLayer?.strokeEnd ?? 0.0
        indicatorView.center = pointAtCircleOfPogress(progress: strokeEnd * 100.0)
        if (presentationLayer == nil ||
            presentationLayer?.strokeEnd == progressMaskLayer.strokeEnd) {
            stopDisplayLink()
        }
    }

    // MARK: - Public Methods
    func increaseCurrentValue(by value: CGFloat) {
        var currentValue = currentValue
        currentValue += value
        currentValue = max(min(toValue, currentValue), fromValue)
        let progress = progressForValue(currentValue)
        setProgress(progress, animated: true)
    }

    func decreaseCurrentValue(by value: CGFloat) {
        increaseCurrentValue(by: -value)
    }
    
    func setProgress(_ progress: CGFloat) {
        setProgress(progress, animated: false)
    }

    func setProgress(_ progress: CGFloat, animated: Bool) {
        if self.progress != progress {
            let progress = min(max(progress, 0), 100)
            self.progress = progress
            updateWithProgress(progress: progress, animated: animated)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let locationA = touch.location(in: self)
        /// 触摸点在圆环上时才响应事件
        return isPointOnIndicator(point: locationA)
    }
    
}

// MARK: - Math Helper
extension OpenCircleProgressView {
    
    func endAngleOfProgress(progress: CGFloat) -> CGFloat {
        var endAngle = fromAngle
        endAngle += (progress / 100) * (toAngle - fromAngle)
        if fromAngle == endAngle {
            endAngle += 0.01
        }
        
        return endAngle
    }
    
    /// 获取特定进度对应圆环上的点坐标
    func pointAtCircleOfPogress(progress: CGFloat) -> CGPoint {
        let endAngle = endAngleOfProgress(progress: progress)
        let point = pointAtCircle(center: circleCenter, radius: circleRadius, angle: endAngle)
        return point
    }
    
    /// 将角度转换成0～360度
    func angleBetween0And2PI(_ angle: CGFloat) -> CGFloat {
        var angle = angle
        if angle < 0 {
            angle += CGFloat(((Int)(-angle / 360) + 1) * 360)
        }
        else if angle > 360 {
            angle -= CGFloat(((Int)(angle / 360)) * 360)
        }
        
        return angle
    }
    
    func pointAtCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
        let radians = angleBetween0And2PI(angle).degreesToRadians
        let dx = radius * cos(radians)
        let dy = radius * sin(radians)
        return CGPoint(x: center.x + dx, y: center.y + dy)
    }
    
    /// 计算圆上两点间的角度
    func angleWithRadius(radius: CGFloat, center: CGPoint, startCenter: CGPoint, endCenter: CGPoint) -> CGFloat {
        //cosA = b^2 + c^2 - a^2 / 2bc
        let a = distanceBetweenPointA(pointA: startCenter, pointB: endCenter)
        let cosA = (2 * radius * radius - a * a) / (2 * radius * radius)
        var angle = acos(cosA).radiansToDegrees
        if startCenter.y < endCenter.y || (endCenter.x - center.x) + (startCenter.x - center.x) >= 0 {
            angle = 360 - angle
        }
        
        return angle
    }
    
    func distanceBetweenPointA(pointA: CGPoint, pointB: CGPoint) -> Double {
        let x = fabs(Double(pointA.x - pointB.x))
        let y = fabs(Double(pointA.y - pointB.y))
        return hypot(x, y) /// hypot(x, y)函数为计算三角形的斜边长度
    }
    
    /// 获取圆上一点，使得该点与已知经过点的连线经过圆心
    /// @param center 圆心坐标
    /// @param radius 圆半径
    /// @param passPoint 坐标系中任一不为圆心的经过点
    func pointAtCircle(center: CGPoint, radius: CGFloat, passPoint: CGPoint) -> CGPoint {
        if center == passPoint {
            return CGPoint(x: center.x + radius, y: center.y)
        }
        
        let dx = passPoint.x - center.x
        let dy = passPoint.y - center.y
        let c = sqrt(dx * dx + dy * dy)
        
        let px = (dx / c) * radius
        let py = (dy / c) * radius
        return CGPoint(x: center.x + px, y: center.y + py)
    }
    
}

//
//  CountdownTimerProgressView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/14.
//

import Foundation
import UIKit
import QuartzCore

class CountdownTimerProgressView: UIView {
    
    /// 进度条颜色
    var lineColor: UIColor = kFocusCountdownTimerColor {
        didSet {
            guard lineColor != oldValue else {
                return
            }
            
            for circleLayer in circleLayers {
                circleLayer.strokeColor = lineColor.cgColor
            }
        }
    }
    
    let fromAngle = -90.0

    /// 最大分钟数
    let maxDuration: TimeInterval = TimeInterval(3 * SECONDS_PER_HOUR)

    /// 最小线条宽度
    let minLineWidth = 2.0
    
    /// 线条宽度步长
    let lineWidthStep = 4.0

    /// 虚线圆环图层
    lazy var dashCircleLayer: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1.2
        layer.lineDashPattern = [NSNumber(value: 2.0),
                                 NSNumber(value: 2.0)]
        return layer
    }()
    
    lazy var tickView: CountdownTimerTickView = {
        return CountdownTimerTickView(frame: bounds)
    }()
    
    /// 参考对照圆环图层
    lazy var referenceLayer: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 1.0
        layer.opacity = 0
        return layer
    }()
    
    /// 指示视图
    lazy var indicatorView: UIView = {
        let indicatorSize = CGSize(width: 12.0, height: 12.0)
        let view = UIView()
        view.size = indicatorSize
        view.layer.cornerRadius = indicatorSize.width / 2.0
        view.layer.borderWidth = 4.0
        view.layer.borderColor = Color(0xFFFFFF, 0.8).cgColor
        return view
    }()
    
    /// 圆环图层
    var circleLayers: [CAShapeLayer] = []
    
    /// 圆环半径
    var circleRadius: Double = 0.0

    /// 当前秒
    fileprivate var _duration: TimeInterval = TimeInterval(SECONDS_PER_MINUTE * 25)
    
    var duration: TimeInterval {
        get {
            return _duration
        }
        
        set {
            _duration = newValue
            updateProgress(animated: false)
        }
    }
    
    func setDuration(_ duration: TimeInterval, animated: Bool) {
        _duration = duration
        updateProgress(animated: animated)
    }
    
    /// 动画定时器
    var displayLink: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMultipleTouchEnabled = false
        tickView.alpha = 0.6
        tickView.scaleLineWidth = 3.0
        addSubview(tickView)
        layer.addSublayer(dashCircleLayer)
        layer.addSublayer(referenceLayer)
        
        /// 添加进度圆环图层
        addProgressCircleLayers()
        
        /// 最后添加指示视图
        addSubview(indicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.padding = UIEdgeInsets(value: 10.0)
        tickView.frame = layoutFrame()

        indicatorView.layer.backgroundColor = UIColor.label.cgColor
        circleRadius = min(self.halfWidth, self.halfHeight)
        dashCircleLayer.strokeColor = UIColor.label.withAlphaComponent(0.4).cgColor
        dashCircleLayer.frame = self.bounds;
        referenceLayer.frame = self.bounds;
        
        for circleLayer in circleLayers {
            circleLayer.frame = self.bounds;
        }
        
        updateDashCircleLayerPath()
        updateReferenceLayerPath()
        updateLayerPaths()
        updateProgress(animated:false)
    }
    
    // MARK: - Circle Layers
    /// 添加进度圆环图层
    private func addProgressCircleLayers() {
        removeAllCircleLayers()
        var layersCount = Int(maxDuration) / SECONDS_PER_HOUR
        if Int(maxDuration) % SECONDS_PER_HOUR != 0 {
            layersCount += 1
        }
        
        var layers = [CAShapeLayer]()
        for i in 0..<layersCount {
            let layer = CAShapeLayer()
            layer.lineCap = CAShapeLayerLineCap.round
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = lineColor.cgColor
            layer.lineWidth = minLineWidth + Double(i) * lineWidthStep
            layers.append(layer)
            self.layer.addSublayer(layer)
        }
        
        circleLayers = layers
        setNeedsLayout()
    }
    
    /// 移除所有图层
    private func removeAllCircleLayers() {
        for circleLayer in circleLayers {
            circleLayer.removeFromSuperlayer()
        }
        
        circleLayers.removeAll()
    }
    
    
    // MARK: - 更新图层
    private func updateDashCircleLayerPath() {
        let path = UIBezierPath(arcCenter: self.bounds.center,
                                radius: circleRadius,
                                startAngle: radians(of: -90),
                                endAngle: radians(of: 270),
                                clockwise: true)
        dashCircleLayer.path = path.cgPath
    }

    /// 初始化圆环图层
    private func updateReferenceLayerPath() {
        let endAngle = endAngle(duration: maxDuration)
        let path = UIBezierPath(arcCenter: self.bounds.center,
                                radius: circleRadius,
                                startAngle: radians(of: -90),
                                endAngle: radians(of: endAngle),
                                clockwise: true)
        
        referenceLayer.path = path.cgPath
    }

    private func updateLayerPaths() {
        let center = self.bounds.center
        for circleLayer in circleLayers {
            let path = UIBezierPath(arcCenter: center,
                                    radius: circleRadius,
                                    startAngle: radians(of: -90),
                                    endAngle: radians(of: 270),
                                    clockwise: true)

            circleLayer.path = path.cgPath
        }
    }
    
    // MARK: - 更新进度
    private func updateProgress(animated: Bool) {
        let toStrokeEnd = strokeEnd(duration: duration)
        if animated {
            startDisplayLink()
            let fromStrokeEnd = self.referenceLayer.strokeEnd
            var duration = fabs(toStrokeEnd - fromStrokeEnd) * 5.0 / 2.0
            duration = min(max(0.5, duration), 2.0)
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            referenceLayer.strokeEnd = toStrokeEnd
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            referenceLayer.strokeEnd = toStrokeEnd
            updateProgress(with: toStrokeEnd)
            CATransaction.commit()
        }
    }
    
    private func updateProgress(with strokeEnd: Double) {
        let angle = endAngle(strokeEnd: strokeEnd)
        let currentLayerIndex = Int((angle - fromAngle) / DEGREES_CIRCLE)
        for (idx, circleLayer) in circleLayers.enumerated() {
            if idx < currentLayerIndex {
                circleLayer.strokeEnd = 1.0
            } else if idx > currentLayerIndex {
                circleLayer.strokeEnd = 0
            } else {
                circleLayer.strokeEnd = (angle - fromAngle - Double(currentLayerIndex) * DEGREES_CIRCLE) / DEGREES_CIRCLE
            }
        }
        
        /// 更新指示视图
        indicatorView.center = indicatorCenter(strokeEnd: strokeEnd)
    }

    // MARK: - DisplayLink
    private func startDisplayLink() {
        if displayLink != nil {
            return;
        }
     
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction))
        displayLink?.add(to: RunLoop.current, forMode: .common)
    }

    private func stopDisplayLink() {
        if displayLink != nil {
            displayLink!.invalidate()
            displayLink = nil
        }
    }
    
    @objc private func displayLinkAction() {
        guard let presentationLayer = referenceLayer.presentation() else {
            stopDisplayLink()
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateProgress(with: presentationLayer.strokeEnd)
        CATransaction.commit()
        
        /// 结束更新
        if presentationLayer.strokeEnd == strokeEnd(duration: duration) {
            stopDisplayLink()
        }
    }
    
    // MARK: - Math Helpers
    private func endAngle(duration: TimeInterval) -> Double {
        let hour = Int(duration) / SECONDS_PER_HOUR /// 整小时数
        let remain = Int(duration) % SECONDS_PER_HOUR
        let angle = Double(hour) * DEGREES_CIRCLE + Double(remain) / Double(SECONDS_PER_HOUR) * DEGREES_CIRCLE
        return fromAngle + angle
    }

    private func endAngle(strokeEnd: Double) -> Double {
        let seconds = strokeEnd * Double(maxDuration)
        return endAngle(duration: seconds)
    }

    private func strokeEnd(duration: TimeInterval) -> Double {
        let progress = duration / maxDuration
        return progress
    }

    /// 获取特定进度对应圆环上的点坐标
    private func indicatorCenter(strokeEnd: Double) -> CGPoint {
        let endAngle = endAngle(strokeEnd: strokeEnd)
        let point = pointAtCircle(center: self.bounds.middlePoint,
                                  radius: circleRadius,
                                  angle: endAngle)
        return point
    }
}

class CountdownTimerTickView: WatchTickView {
    override func scaleLength(at index: Int) -> CGFloat? {
        if index % 5 == 0 {
            return 10
        }
        
        return 4
    }
}

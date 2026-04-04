//
//  TodoProgressSlider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/4.
//

import Foundation
import UIKit

class TodoProgressSlider: UIView, UIGestureRecognizerDelegate {

    var fromValue: CGFloat = 0
    
    var toValue: CGFloat = 100
 
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
    
    lazy var progressView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .primary
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
        imageView.backgroundColor = .primary
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
    
    var barRect: CGRect = .zero
    var barCenterY: CGFloat = 0
    var processPan: Bool = false
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
        
        // 计算条形进度条的矩形区域
        let padding = lineWidth / 2.0
        barRect = CGRect(x: padding,
                         y: (bounds.height - lineWidth) / 2.0,
                         width: bounds.width - 2 * padding,
                         height: lineWidth)
        barCenterY = bounds.height / 2.0
        
        backImageView.frame = bounds
        progressView.frame = backImageView.frame
        
        updateMaskLayerPath()
        updateProgress()
        valueLabel.frame = indicatorView.bounds
    }
    
    private func updateMaskLayerPath() {
        // 创建水平条形路径
        let path = UIBezierPath()
        path.move(to: CGPoint(x: barRect.minX, y: barRect.midY))
        path.addLine(to: CGPoint(x: barRect.maxX, y: barRect.midY))
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
            }
        case .changed:
            if processPan {
                updateProgressWithTouchPoint(point: location, animated: false)
            }
            
        default:
            processPan = false
        }
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if processPan {
            return
        }
        
        let location = gesture.location(in: self)
        TPImpactFeedback.impactWithSoftStyle()
        updateProgressWithTouchPoint(point: location, animated: true)
    }
    
    private func isPointOnIndicator(point: CGPoint) -> Bool {
        let dx = -lineWidth / 2.0
        var rect = indicatorView.frame
        rect = rect.insetBy(dx: dx, dy: dx)
        return rect.contains(point)
    }
    
    private func updateProgressWithTouchPoint(point: CGPoint, animated: Bool) {
        // 根据触摸点的x坐标计算进度
        let relativeX = max(barRect.minX, min(point.x, barRect.maxX))
        let progressRatio = (relativeX - barRect.minX) / barRect.width
        let toProgress = progressRatio * 100.0
        
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
            indicatorView.center = pointAtBarOfProgress(progress: progress)
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
        indicatorView.center = pointAtBarOfProgress(progress: strokeEnd * 100.0)
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

    func setProgress(_ progress: CGFloat, animated: Bool = false) {
        if self.progress != progress {
            let progress = min(max(progress, 0), 100)
            self.progress = progress
            updateWithProgress(progress: progress, animated: animated)
        }
    }

    func setCurrentValue(_ value: CGFloat, animated: Bool = false) {
        let progress = progressForValue(value)
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
    
    // MARK: - Helpers
    /// 获取特定进度对应条形上的点坐标
    func pointAtBarOfProgress(progress: CGFloat) -> CGPoint {
        let x = barRect.minX + (barRect.width * progress / 100.0)
        let y = barCenterY
        return CGPoint(x: x, y: y)
    }
}

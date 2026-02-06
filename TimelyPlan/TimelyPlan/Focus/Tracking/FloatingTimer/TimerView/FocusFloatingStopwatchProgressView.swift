//
//  FocusFloatingStopwatchProgressView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/27.
//

import Foundation
import UIKit

class FocusFloatingStopwatchProgressView: UIView {
    
    /// 当前进度
    var progress: CGFloat {
        get {
            return _progress
        }
        
        set {
            setProgress(newValue, animated: false)
        }
    }
    
    private var _progress: CGFloat = 0.0
    
    var scaleLineWidth: CGFloat = 1.5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var scaleCount: Int = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var backScaleColor: UIColor = .label.withAlphaComponent(0.2) {
        didSet {
            setNeedsLayout()
        }
    }

    var foreScaleColor: UIColor = UIColor.label {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 进度图层
    private var progressLayer = CAShapeLayer()
    
    /// 底部刻度图层
    private var backLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 1.5)
        progressLayer.strokeEnd = 0.0
        backLayer.strokeEnd = 1.0
        layer.addSublayer(backLayer)
        layer.addSublayer(progressLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backLayer.lineWidth = scaleLineWidth
        backLayer.strokeColor = backScaleColor.cgColor
        backLayer.frame = layoutFrame()
        
        progressLayer.lineWidth = scaleLineWidth
        progressLayer.strokeColor = foreScaleColor.cgColor
        progressLayer.frame = backLayer.frame
        updateLayerPath()
    }
    
    private func updateLayerPath() {
        let layoutFrame = layoutFrame()
        /// 计算间隔
        var margin = (layoutFrame.width - scaleLineWidth * CGFloat(scaleCount)) / CGFloat(scaleCount - 1)
        margin = max(0.0, margin)
        
        let path = UIBezierPath()
        for i in 0..<scaleCount {
            let x = CGFloat(i) * (margin + scaleLineWidth) + scaleLineWidth / 2.0
            path.move(to: CGPoint(x: x, y: layoutFrame.height))
            path.addLine(to: CGPoint(x: x, y: 0.0))
        }

        self.backLayer.path = path.cgPath
        self.progressLayer.path = path.cgPath
    }
    
    // MARK: - Public Methods
    func setProgress(_ progress: CGFloat, animated: Bool) {
        _progress = validatedProgress(progress)
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        progressLayer.strokeEnd = _progress
        CATransaction.commit()
    }
    
    func setDuration(_ duration: TimeInterval) {
        progress = duration.seconds / CGFloat(SECONDS_PER_MINUTE)
    }
}

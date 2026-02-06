//
//  PomodoroProgressView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/9.
//

import Foundation
import UIKit

class FocusPomodoroProgressView: UIView {
    
    var stepIndex: Int? {
        didSet {
            if stepIndex != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
            let progress = validatedProgress(progress)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.strokeStart = progress
            CATransaction.commit()
        }
    }
    
    var config: FocusPomodoroConfig {
        get { return circleView.config }
        set { circleView.config = newValue }
    }
    
    private let circleView = PomodoroCircleView()
    
    private let progressLayer = PomodoroFragmentLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        circleView.alpha = 0.25
        addSubview(circleView)

        progressLayer.lineWidth = circleView.circleWidth
        progressLayer.strokeColor = Color(0x4A4DFF).cgColor
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.frame = bounds
        progressLayer.frame = bounds.inset(by: UIEdgeInsets(value: circleView.borderLineWidth))
        updateProgressFragment()
        updateProgressColor()
    }
    
    private func updateProgressFragment() {
        if let fragment = config.fragment(atIndex: stepIndex) {
            progressLayer.fragments = [fragment]
        } else {
            progressLayer.fragments = []
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeStart = 0.0
        CATransaction.commit()
    }
    
    private func updateProgressColor() {
        var progressColor: UIColor
        guard let phase = config.phase(atIndex: stepIndex) else {
            return
        }
        
        switch phase {
        case .focus:
            progressColor = FocusPomodoroConfig.focusColor
        case .shortBreak:
            progressColor = FocusPomodoroConfig.shortBreakColor
        case .longBreak:
            progressColor = FocusPomodoroConfig.longBreakColor
        }
    
        progressLayer.strokeColor = progressColor.cgColor
    }
}


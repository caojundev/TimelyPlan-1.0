//
//  PomodoroCircleView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/16.
//

import Foundation
import UIKit

class PomodoroCircleView: UIView {
    
    let borderLineWidth = 3.0
    let circleWidth = 30.0
    
    var config: FocusPomodoroConfig = FocusPomodoroConfig() {
        didSet {
            reloadData()
        }
    }
    
    private var focusLayer: PomodoroFragmentLayer = PomodoroFragmentLayer()
    
    private var shortBreakLayer: PomodoroFragmentLayer = PomodoroFragmentLayer()
    
    private var longBreakLayer: PomodoroFragmentLayer = PomodoroFragmentLayer()
    
    private var borderLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(borderLayer)
        self.layer.addSublayer(focusLayer)
        self.layer.addSublayer(shortBreakLayer)
        self.layer.addSublayer(longBreakLayer)
        configureUI()
        reloadData(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = borderLineWidth
        borderLayer.strokeColor = Color(0x262E55).cgColor
        focusLayer.lineWidth = circleWidth
        shortBreakLayer.lineWidth = circleWidth
        longBreakLayer.lineWidth = circleWidth
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderLayer.frame = self.bounds
        let layerFrame = self.bounds.inset(by: UIEdgeInsets(value: borderLineWidth))
        focusLayer.frame = layerFrame
        focusLayer.strokeColor = FocusPomodoroConfig.focusColor.cgColor
        
        shortBreakLayer.frame = layerFrame
        shortBreakLayer.strokeColor = FocusPomodoroConfig.shortBreakColor.cgColor
        
        longBreakLayer.frame = layerFrame
        longBreakLayer.strokeColor = FocusPomodoroConfig.longBreakColor.cgColor
        
        updateBorderLayerPath()
    }
    
    func updateBorderLayerPath() {
        let center = bounds.middlePoint
        let outerRadius = bounds.width / 2.0 - borderLineWidth / 2.0
        let innerRadius = outerRadius - circleWidth - borderLineWidth

        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x + outerRadius, y: center.y))
        path.addArc(withCenter: center,
                    radius: outerRadius,
                    startAngle: radians(of: 0.0),
                    endAngle: radians(of: 360.0),
                    clockwise: true)

        path.move(to: CGPoint(x: center.x + innerRadius, y: center.y))
        path.addArc(withCenter: center,
                    radius: innerRadius,
                    startAngle: radians(of: 0.0),
                    endAngle: radians(of: 360.0),
                    clockwise: true)
        borderLayer.path = path.cgPath
    }
    
    private func updateFragments() {
        let duration = config.durationPerRound()
        
        /// 专注
        let dFocusProgress = config.focusDuration / duration
        var focusFragments = [PomodoroFragment]()
        for i in 0..<config.pomosCountPerCycle {
            let from = Double(i) * (config.focusDuration + config.shortBreakDuration) / duration
            let to = from + dFocusProgress
            let fragment = PomodoroFragment(fromProgress: from, toProgress: to)
            focusFragments.append(fragment)
        }
        
        focusLayer.fragments = focusFragments
        
        /// 短休
        let dshortBreakProgress = config.shortBreakDuration / duration
        var shortBreakFragments = [PomodoroFragment]()
        for i in 1..<config.pomosCountPerCycle {
            let from = (Double(i) * config.focusDuration + Double(i - 1) * config.shortBreakDuration) / duration
            let to = from + dshortBreakProgress
            let fragment = PomodoroFragment(fromProgress: from, toProgress: to)
            shortBreakFragments.append(fragment)
        }
        
        shortBreakLayer.fragments = shortBreakFragments
        
        /// 长休
        let dLongBreakProgress = config.longBreakDuration / duration
        let fragment = PomodoroFragment(fromProgress: 1.0 - dLongBreakProgress, toProgress: 1.0)
        longBreakLayer.fragments = [fragment]
    }

    public func reloadData() {
        reloadData(animated: false)
    }

    public func reloadData(animated: Bool) {
        updateFragments()
        focusLayer.updatePathAnimated(animated)
        shortBreakLayer.updatePathAnimated(animated)
        longBreakLayer.updatePathAnimated(animated)
    }

    public func animte(for phase: FocusPomodoroPhase) {
        let animation = CAKeyframeAnimation.scaleKeyframeAnimation(withDuration: 0.5)
        switch phase {
        case .focus:
            focusLayer.add(animation, forKey: nil)
        case .shortBreak:
            shortBreakLayer.add(animation, forKey: nil)
        case .longBreak:
            longBreakLayer.add(animation, forKey: nil)
        }
    }
    
}

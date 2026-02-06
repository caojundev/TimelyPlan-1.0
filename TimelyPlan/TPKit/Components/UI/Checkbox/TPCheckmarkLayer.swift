//
//  TPCheckmarkLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/19.
//

import Foundation
import UIKit

class TPCheckmarkLayer: CAShapeLayer {
    
    static let kDefaultLineWidth: CGFloat = 3.0
    
    private var _isChecked: Bool = false
    
    var isChecked: Bool {
        get {
            return _isChecked
        }
        
        set {
            setChecked(newValue, animated: false)
        }
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setupLayer()
    }
    
    override init() {
        super.init()
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayer() {
        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.white.cgColor
        lineCap = .round
        lineJoin = .round
        lineWidth = TPCheckmarkLayer.kDefaultLineWidth
        strokeStart = 0
        strokeEnd = 0
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        updateCheckmarkLayerPath()
    }
    
    private func updateCheckmarkLayerPath() {
        let length = frame.size.width
        let beginPoint = CGPoint(x: length * 0.25, y: length * 0.6)
        let endPoint = CGPoint(x: length * 0.75, y: length * 0.25)
        let middlePoint = CGPoint(x: length * 0.5, y: length * 0.75)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: beginPoint)
        bezierPath.addLine(to: middlePoint)
        bezierPath.addLine(to: endPoint)
        self.path = bezierPath.cgPath
    }
    
    func setChecked(_ checked: Bool, animated: Bool) {
        _isChecked = checked
        CATransaction.begin()
        if animated {
            CATransaction.setAnimationDuration(0.2)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            self.strokeEnd = checked ? 1.0 : 0
        } else {
            CATransaction.setDisableActions(true)
            self.strokeEnd = checked ? 1.0 : 0
        }
        
        self.strokeEnd = checked ? 1.0 : 0
        CATransaction.commit()
    }
}

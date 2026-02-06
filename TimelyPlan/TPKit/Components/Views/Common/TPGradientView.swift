//
//  TPGradientView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/4.
//

import Foundation
import UIKit

class TPGradientView: UIView {
    
    enum Style: Int {
        case topToBottom
        case bottomToTop
        case leftToRight
        case rightToLeft
    }

    var fromColor: UIColor = Color(light: 0xFFFFFF, 0.0, dark: 0x000000, 0.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var toColor: UIColor = Color(light: 0xFFFFFF,1.0, dark: 0x000000, 1.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    var startPoint: CGPoint
    var endPoint: CGPoint
    
    convenience init() {
        self.init(frame: .zero, style: .topToBottom)
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, style: .topToBottom)
    }
    
    convenience init(style: TPGradientView.Style) {
        self.init(frame: .zero, style: style)
    }
    
    init(frame: CGRect, style: TPGradientView.Style) {
        switch style {
        case .topToBottom:
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: 0, y: 1)
        case .bottomToTop:
            startPoint = CGPoint(x: 0, y: 1)
            endPoint = CGPoint(x: 0, y: 0)
        case .leftToRight:
            startPoint = CGPoint(x: 0.0, y: 0.5)
            endPoint = CGPoint(x: 1.0, y: 0.5)
        case .rightToLeft:
            startPoint = CGPoint(x: 1.0, y: 0.5)
            endPoint = CGPoint(x: 0.0, y: 0.5)
        }
        
        super.init(frame:frame)
        layer.addSublayer(gradientLayer)
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
    }
}

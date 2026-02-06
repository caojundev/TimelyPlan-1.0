//
//  TPDragFocusIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/31.
//

import Foundation
import UIKit

class TPDragFocusIndicatorView: UIView {
    
    /// 圆角半径
    var cornerRadius: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 线条宽度
    var borderWidth: CGFloat = 2.0 {
        didSet {
            focusLayer.lineWidth = borderWidth
        }
    }

    /// 线条颜色
    var borderColor: UIColor = Color(0x007AFF) {
        didSet {
            focusLayer.strokeColor = borderColor.cgColor
        }
    }
    
    /// 聚焦背景色
    var fillColor: UIColor = Color(0x007AFF, 0.1)  {
        didSet {
            focusLayer.fillColor = fillColor.cgColor
        }
    }
    
    
    private lazy var focusLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.opacity = 1.0
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.padding = UIEdgeInsets(value: borderWidth)
        self.layer.addSublayer(focusLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        focusLayer.frame = bounds
        
        let roundedRect = bounds.inset(by: padding)
        let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        focusLayer.path = path.cgPath
        focusLayer.lineWidth = borderWidth
        focusLayer.strokeColor = borderColor.cgColor
        focusLayer.fillColor = fillColor.cgColor
    }
    
}

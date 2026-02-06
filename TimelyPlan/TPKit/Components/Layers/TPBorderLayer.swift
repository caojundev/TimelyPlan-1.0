//
//  TPBorderLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/11.
//

import Foundation
import QuartzCore

class TPBorderLayer: CAShapeLayer {
    
    var padding: UIEdgeInsets = .zero

    var lineDashValues: [CGFloat]? {
        didSet {
            updateLineDashPattern()
        }
    }
    
    func updateLineDashPattern() {
        guard let lineDashValues = lineDashValues else {
            lineDashPattern = nil
            return
        }

        let pattern = lineDashValues.map { return NSNumber(value: $0)}
        lineDashPattern = pattern
    }
    
    /// 边框线条颜色
    var lineColor: UIColor = Color(0x888888, 0.6)
    
    override init(layer: Any) {
        super.init(layer: layer)
        setupUI()
    }
    
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 1.0
        self.cornerRadius = 10.0
        self.lineDashValues = [3, 3]
        updateLineDashPattern()
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        let layoutFrame = bounds.inset(by: padding)
        self.strokeColor = lineColor.cgColor
        self.path = UIBezierPath(roundedRect: layoutFrame,
                                cornerRadius: cornerRadius).cgPath
    }
}

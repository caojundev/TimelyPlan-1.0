//
//  AuxiliaryView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/29.
//

import Foundation
import QuartzCore

class ChartGuidelineView: UIView {
    
    /// x轴辅助线布局
    var xGuideline: ChartGuideline? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// y轴辅助线布局
    var yGuideline: ChartGuideline? {
        didSet {
            setNeedsLayout()
        }
    }
    
    private lazy var xLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 1.0
        return layer
    }()
    
    private lazy var yLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 1.0
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
        isUserInteractionEnabled = false
        self.layer.addSublayer(self.xLayer)
        self.layer.addSublayer(self.yLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        xLayer.frame = bounds
        yLayer.frame = bounds
        xLayer.strokeColor = xGuideline?.color.cgColor
        yLayer.strokeColor = yGuideline?.color.cgColor
        updateXLinesLayerPath()
        updateYLinesLayerPath()
    }
    
    private func updateXLinesLayerPath() {
        guard let guideline = xGuideline, let values = guideline.values else {
            xLayer.path = nil
            return
        }
        
        xLayer.lineDashPattern = guideline.dashPattern
  
        let path = UIBezierPath()
        for value in values {
            let length = guideline.range.length
            var x: CGFloat
            if length == 0.0 {
                x = 0.0
            } else {
                x = width * (value - guideline.range.minValue) / length
            }

            if x == 0.0 {
                x += xLayer.lineWidth / 2.0
            } else if x == width {
                x -= xLayer.lineWidth / 2.0
            }
            
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        
        xLayer.path = path.cgPath
    }

    private func updateYLinesLayerPath() {
        guard let guideline = yGuideline, let values = guideline.values else {
            yLayer.path = nil
            return
        }
        
        yLayer.lineDashPattern = guideline.dashPattern
        
        let path = UIBezierPath()
        for value in values {
            var y: CGFloat
            let length = guideline.range.length
            if length == 0.0 {
                y = height
            } else {
                y = height - height * (value - guideline.range.minValue) / length
            }
            
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: bounds.width, y: y))
        }
        
        yLayer.path = path.cgPath
    }
}

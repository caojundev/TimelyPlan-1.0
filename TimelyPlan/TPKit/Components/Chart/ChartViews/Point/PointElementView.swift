//
//  ChartDot.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/30.
//

import Foundation
import UIKit

class PointElementView: UIView, ChartHighlightEelement {
    
    /// 标记
    var mark: ChartMark

    var highlightText: String? {
        return mark.highlightText
    }
    
    private var shapeLayer = CAShapeLayer()
    
    convenience init(mark: ChartMark) {
        self.init(frame: .zero, mark: mark)
    }
    
    init(frame: CGRect, mark: ChartMark) {
        self.mark = mark
        super.init(frame: frame)

        shapeLayer.lineWidth = 2.0
        shapeLayer.strokeColor = Color(0xFFFFFF, 0.5).cgColor
        shapeLayer.fillColor = Color(0x5856D6).cgColor
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        
        let rect = bounds.middleCircleRect
        let cornerRadii = CGSize(width: rect.width / 2.0, height: rect.width / 2.0)
        let path = UIBezierPath(roundedRect: rect,
                                  byRoundingCorners: .allCorners,
                                  cornerRadii: cornerRadii)
        shapeLayer.path = path.cgPath
    }
}

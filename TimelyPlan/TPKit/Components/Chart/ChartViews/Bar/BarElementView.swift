//
//  ChartBar.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/28.
//

import UIKit

class BarElementView: UIView, ChartHighlightEelement {

    /// 标记
    var mark: ChartMark

    var highlightText: String? {
        return mark.highlightText
    }
    
    /// 圆角位置，默认全为圆角
    var barRoundingCorners: UIRectCorner = .allCorners

    /// 圆角半径
    var barRadius: CGFloat = 4.0
    
    /// 柱颜色
    var barColor: UIColor = Color(0x5856D6) {
        didSet {
            barLayer.fillColor = barColor.cgColor
        }
    }
    
    var barBackColor: UIColor? {
        didSet {
            backgroundColor = barBackColor
        }
    }
    
    var grade: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 柱图层
    private var barLayer = CAShapeLayer()
    
    /// 背景图层
    private var maskLayer = CAShapeLayer()
    
    convenience init(mark: ChartMark) {
        self.init(frame: .zero, mark: mark)
    }
    
    init(frame: CGRect, mark: ChartMark) {
        self.mark = mark
        super.init(frame: frame)
        clipsToBounds = true
        layer.addSublayer(barLayer)
        layer.mask = maskLayer
        barRoundingCorners = [.topLeft, .topRight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = barBackColor ?? .clear
        maskLayer.path = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: barRoundingCorners,
                                      cornerRadii: CGSize(barRadius, barRadius)).cgPath
        
        let barHeight = grade * bounds.height
        let barTop = bounds.height - barHeight
        barLayer.frame = CGRect(x: 0.0, y: barTop, width: bounds.width, height: barHeight)
        
        let barFrame = barLayer.bounds
        let barPath = UIBezierPath(roundedRect: barFrame,
                                  byRoundingCorners: barRoundingCorners,
                                  cornerRadii: CGSize(barRadius, barRadius))
        barLayer.path = barPath.cgPath
    }
}

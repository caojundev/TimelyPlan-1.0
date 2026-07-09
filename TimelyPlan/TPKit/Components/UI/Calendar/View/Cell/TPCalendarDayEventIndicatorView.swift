//
//  TPCalendarDayEventIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/9.
//

import Foundation
import UIKit

// MARK: - 单天事项指示视图
class TPCalendarDayEventIndicatorView: UIView {
    
    private var eventColors: [UIColor]?
    
    // 布局常量
    private static let indicatorHeight: CGFloat = 4.8 // 圆点直径
    private static let maxDotsCount = 3 // 最多显示圆点数
    private static let dotSpacing: CGFloat = 3.0 // 圆点之间的间距
    
    private var lastDrawnWidth = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentWidth = bounds.width
        if currentWidth != lastDrawnWidth {
            lastDrawnWidth = currentWidth
            setNeedsDisplay()
        }
    }
    
    func configure(colors: [UIColor]?) {
        if eventColors != colors {
            eventColors = colors
            setNeedsDisplay()
        }
    }
    
    func clear() {
        eventColors = nil
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
                let eventColors = eventColors,
                !eventColors.isEmpty else { return }
        lastDrawnWidth = bounds.width
        
        // 取前3个颜色
        let displayColors = Array(eventColors.prefix(Self.maxDotsCount))
        
        // 在视图底部居中绘制指示器
        let indicatorY = bounds.height - Self.indicatorHeight - 2.0
        
        drawDots(context: context, y: indicatorY, colors: displayColors)
    }
    
    /// 绘制小圆点（水平居中）
    private func drawDots(context: CGContext, y: CGFloat, colors: [UIColor]) {
        let dotDiameter = Self.indicatorHeight
        let spacing = Self.dotSpacing
        
        // 计算所有圆点的总宽度
        let totalWidth = CGFloat(colors.count) * dotDiameter + CGFloat(max(0, colors.count - 1)) * spacing
        
        // 在整个视图中居中起始位置
        var startX = (bounds.width - totalWidth) / 2.0
        
        for color in colors {
            let dotRect = CGRect(x: startX, y: y, width: dotDiameter, height: dotDiameter)
            
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: dotRect)
            
            startX += dotDiameter + spacing
        }
    }
}

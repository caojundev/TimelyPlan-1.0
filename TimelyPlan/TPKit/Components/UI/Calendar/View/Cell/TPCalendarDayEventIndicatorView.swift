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
    private static let indicatorHeight: CGFloat = 5.6 // 圆点直径
    private static let maxDotsCount = 3 // 最多显示圆点数
    private static let dotSpacing: CGFloat = 3.0 // 圆点之间的间距（保留兼容，但重叠模式下不使用）
    
    // 重叠相关常量
    private static let overlapRatio: CGFloat = 0.1 // 重叠比例（0~1，0为不重叠，1为完全重叠）
    private static let borderWidth: CGFloat = 1.2 // 描边宽度
    
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
        
        drawOverlappingDots(context: context, y: indicatorY, colors: displayColors)
    }
    
    /// 绘制重叠的小圆点（水平居中）
    private func drawOverlappingDots(context: CGContext, y: CGFloat, colors: [UIColor]) {
        let dotDiameter = Self.indicatorHeight
        let overlapOffset = dotDiameter * Self.overlapRatio // 每个圆点相对于前一个的偏移量
        
        // 计算所有圆点占用的总宽度（考虑重叠）
        // 总宽度 = 第一个圆的完整宽度 + 后续每个圆的偏移量
        let totalWidth = dotDiameter + CGFloat(max(0, colors.count - 1)) * (dotDiameter - overlapOffset)
        
        // 在整个视图中居中起始位置
        let startX = (bounds.width - totalWidth) / 2.0
        
        // 从右往左绘制，让最右边的圆点在底层，最左边的圆点在顶层
        // 这样用户可以看到完整的重叠效果
        for (index, color) in colors.enumerated() {
            let dotRect = CGRect(x: startX + CGFloat(index) * (dotDiameter - overlapOffset),
                                y: y,
                                width: dotDiameter,
                                height: dotDiameter)
            
            // 绘制填充
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: dotRect)
            
            // 绘制描边（使用稍深一点的颜色或白色）
            context.setStrokeColor(UIColor.systemBackground.cgColor)
            context.setLineWidth(Self.borderWidth)
            context.strokeEllipse(in: dotRect)
        }
    }
}

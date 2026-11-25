//
//  WSFocusMonthHeatMapView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

/// 月专注热力图视图。
///
/// 按日历网格绘制当月每一天的热力色块，前后月的补位日期不绘制；
/// 色块尺寸按可用区域等比计算并居中，保证不同尺寸组件下的格子始终为正方形。
class WSFocusMonthHeatMapView: UIView {
    
    /// 本月日期，含前后月补位，按日历顺序排列
    var days: [Date] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 本月月份，用于过滤补位日期
    var month: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 每日等级，key 为日
    var dayLevels: [Int: Int] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 分级颜色，复用统计页的热力分级
    var levels: [HeatMapLevel] = DayHeatMapView.defaultLevels()
    
    /// 色块间距
    var itemSpacing: CGFloat = 3.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 色块圆角
    var itemCornerRadius: CGFloat = 3.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isOpaque = false
        self.contentMode = .redraw
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard !days.isEmpty, !levels.isEmpty else {
            return
        }
        
        let rowCount = Int(ceil(Double(days.count) / Double(DAYS_PER_WEEK)))
        guard rowCount > 0 else {
            return
        }
        
        /// 色块按正方形绘制，宽高取可用区域的较小值
        let maxWidth = (bounds.width - itemSpacing * CGFloat(DAYS_PER_WEEK - 1)) / CGFloat(DAYS_PER_WEEK)
        let maxHeight = (bounds.height - itemSpacing * CGFloat(rowCount - 1)) / CGFloat(rowCount)
        let side = min(maxWidth, maxHeight)
        guard side > 0.0 else {
            return
        }
        
        let gridWidth = side * CGFloat(DAYS_PER_WEEK) + itemSpacing * CGFloat(DAYS_PER_WEEK - 1)
        let gridHeight = side * CGFloat(rowCount) + itemSpacing * CGFloat(rowCount - 1)
        let originX = (bounds.width - gridWidth) / 2.0
        let originY = (bounds.height - gridHeight) / 2.0
        let cornerRadius = min(itemCornerRadius, side / 2.0)
        
        for (index, date) in days.enumerated() {
            guard date.month == month else {
                continue
            }
            
            let column = index % DAYS_PER_WEEK
            let row = index / DAYS_PER_WEEK
            let rect = CGRect(x: originX + CGFloat(column) * (side + itemSpacing),
                              y: originY + CGFloat(row) * (side + itemSpacing),
                              width: side,
                              height: side)
            
            let levelIndex = dayLevels[date.day] ?? 0
            let level = levels[min(max(levelIndex, 0), levels.count - 1)]
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            level.color.setFill()
            path.fill()
        }
    }
}

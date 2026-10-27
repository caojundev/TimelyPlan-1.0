//
//  WSHabitWeekReportView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 周报告视图

/// 习惯周报告视图。
///
/// 一行等分七天，每天按报告样式绘制色块；色块保持正方形并在单元格内居中，
/// 边长取列宽与可用高度中的较小值，行高变化时同样适用。
class WSHabitWeekReportView: UIView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 相邻两天之间的间距
        static let itemSpacing: CGFloat = 4.0
        
        /// 色块与上下边缘的最小间距
        static let verticalInset: CGFloat = 4.0
    }
    
    /// 一周每天的数据，按日期顺序排列
    var dayItems: [WSHabitDayDataItem] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 色块最大宽度。行宽或行高较大时由它限制色块边长，避免色块过大
    var maxItemWidth: CGFloat = 24.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isOpaque = false
        /// 尺寸变化时由 contentMode 触发重绘
        contentMode = .redraw
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 绘制
    override func draw(_ rect: CGRect) {
        guard !dayItems.isEmpty, bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        /// 色块取列宽与行高中的较小值，并受最大宽度限制
        let columnWidth = bounds.width / CGFloat(DAYS_PER_WEEK)
        let side = min(min(columnWidth - Metrics.itemSpacing,
                           bounds.height - Metrics.verticalInset * 2.0),
                       maxItemWidth)
        guard side > 0.0 else {
            return
        }
        
        for (index, dayItem) in dayItems.enumerated() {
            let dayFrame = CGRect(x: CGFloat(index) * columnWidth + (columnWidth - side) / 2.0,
                                  y: (bounds.height - side) / 2.0,
                                  width: side,
                                  height: side)
            WSHabitReportDayPainter.draw(dayItem, in: dayFrame)
        }
    }
}

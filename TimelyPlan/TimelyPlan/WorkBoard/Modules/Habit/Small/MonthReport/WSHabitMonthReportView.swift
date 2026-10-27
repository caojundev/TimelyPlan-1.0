//
//  WSHabitMonthReportView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 月报告视图

/// 习惯月报告视图。
///
/// 绘制方式与习惯报告页的月视图一致：按日历网格绘制当月每一天，
/// 进度日按完成比例叠加任务颜色，非计划日、跳过、失败绘制报告图标。
/// 日期只给出当月，前导空格由首日与周开始日计算；色块按正方形绘制并在可用区域内居中。
class WSHabitMonthReportView: UIView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 列间距
        static let itemMargin: CGFloat = 3.0
        
        /// 行间距
        static let lineSpacing: CGFloat = 3.0
    }
    
    /// 当月每天的数据，按日期顺序排列
    var dayItems: [WSHabitDayDataItem] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 周开始日
    var firstWeekday: Weekday = HabitSetting.shared.firstWeekday {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isOpaque = false
        /// 尺寸变化时由 contentMode 触发重绘，布局过程中的位置变化不必重复重绘
        contentMode = .redraw
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 绘制
    override func draw(_ rect: CGRect) {
        guard let firstItem = dayItems.first, bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        let leadingCount = leadingBlankCount(for: firstItem.date)
        let rowCount = (leadingCount + dayItems.count + DAYS_PER_WEEK - 1) / DAYS_PER_WEEK
        guard rowCount > 0 else {
            return
        }
        
        /// 色块按正方形绘制，宽高取可用区域的较小值
        let maxWidth = (bounds.width - CGFloat(DAYS_PER_WEEK - 1) * Metrics.itemMargin) / CGFloat(DAYS_PER_WEEK)
        let maxHeight = (bounds.height - CGFloat(rowCount - 1) * Metrics.lineSpacing) / CGFloat(rowCount)
        let side = min(maxWidth, maxHeight)
        guard side > 0.0 else {
            return
        }
        
        let gridWidth = side * CGFloat(DAYS_PER_WEEK) + Metrics.itemMargin * CGFloat(DAYS_PER_WEEK - 1)
        let gridHeight = side * CGFloat(rowCount) + Metrics.lineSpacing * CGFloat(rowCount - 1)
        let originX = (bounds.width - gridWidth) / 2.0
        let originY = (bounds.height - gridHeight) / 2.0
        
        for (index, dayItem) in dayItems.enumerated() {
            let position = leadingCount + index
            let dayFrame = CGRect(x: originX + CGFloat(position % DAYS_PER_WEEK) * (side + Metrics.itemMargin),
                                  y: originY + CGFloat(position / DAYS_PER_WEEK) * (side + Metrics.lineSpacing),
                                  width: side,
                                  height: side)
            WSHabitReportDayPainter.draw(dayItem, in: dayFrame)
        }
    }
    
    /// 当月首日在日历网格中的前导空格数
    private func leadingBlankCount(for date: Date) -> Int {
        let offset = date.weekday - firstWeekday.rawValue
        return offset < 0 ? offset + DAYS_PER_WEEK : offset
    }
}

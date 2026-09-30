//
//  CalendarPanelMiniMonthView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/30.
//

import Foundation
import UIKit

/// 面板月历挂件：绘制某个月份的小月历（参考 CalendarYearMonthCell 的绘制方式）
class CalendarPanelMiniMonthView: UIView {
    
    /// 配置信息
    struct Config {
        
        /// 显示星期
        var showsWeekdaySymbols = true
        
        /// 边间距
        var padding = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 8.0, right: 8.0)
        
        /// 相邻月份天的透明度（上月末、下月初）
        var adjacentAlpha = 0.4
        
        /// 星期与日期之间的间距
        var weekdaySpacing = 1.0
        
        var weekdayFontSize = 10.0
        
        /// 字号范围
        var minimumFontSize = 6.0
        var maximumFontSize = 13.0
        
        /// 星期字号比例（相对单格宽度）
        var weekdayFontRatio = 0.45
        
        /// 日期字号比例（相对单格宽高较小值）
        var dayFontRatio = 0.55
        
        /// 文字颜色
        var weekdayColor = UIColor.secondaryLabel
        var dayColor = Color(light: 0x232323, dark: 0xf2f2f2)
        var weekendColor = UIColor.systemGray3
        
        /// 今天的文字颜色
        var todayColor = CalendarYearConfig.todayColor
        
        /// 当前周（页面第一天所在周）的背景色
        var currentWeekColor = UIColor.systemBlue.withAlphaComponent(0.24)
        
        /// 当前周背景的圆角
        var currentWeekCornerRadius = 4.0
    }
    
    /// 配置信息
    var config: Config = Config() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 显示的第一天（显示其所在月份）
    var firstDay: Date? {
        didSet {
            /// 当前周高亮依赖具体的天，同一月份内切换周也要重绘
            setNeedsDisplay()
        }
    }
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday {
        didSet {
            if firstWeekday != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        /// 尺寸变化时重新绘制，避免复用旧的绘制内容
        contentMode = .redraw
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        guard let firstDay = firstDay,
              bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        /// 显示月份
        let monthDate = firstDay.startOfMonth()
        let daysCount = monthDate.numberOfDaysInMonth()
        /// 当月 1 号在网格中的列（从 0 开始）
        let firstColumn = (monthDate.weekday - firstWeekday.rawValue + 7) % 7
        /// 行数按当月实际周数
        let rowsCount = Int(ceil(Double(firstColumn + daysCount) / 7.0))
        guard daysCount > 0, rowsCount > 0 else {
            return
        }
        
        /// 内容区域（边间距内）
        let contentFrame = bounds.inset(by: config.padding)
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        let dayWidth = contentFrame.width / 7.0
        
        /// 星期
        var dateAreaTop = contentFrame.minY
        if config.showsWeekdaySymbols {
            let weekdayFont = UIFont.boldSystemFont(ofSize: config.weekdayFontSize)
            let weekdayAttributes: [NSAttributedString.Key: Any] = [
                .font: weekdayFont,
                .foregroundColor: config.weekdayColor
            ]
            let weekdays = Date.veryShortWeekdaySymbols(firstWeekday: firstWeekday.rawValue)
            for (index, weekday) in weekdays.enumerated() {
                let weekdaySize = weekday.size(withAttributes: weekdayAttributes)
                let x = contentFrame.minX + CGFloat(index) * dayWidth + (dayWidth - weekdaySize.width) / 2.0
                weekday.draw(at: CGPoint(x: x, y: dateAreaTop),
                             withAttributes: weekdayAttributes)
            }
            dateAreaTop += ceil(weekdayFont.lineHeight) + config.weekdaySpacing
        }
        
        let dayHeight = (contentFrame.maxY - dateAreaTop) / CGFloat(rowsCount)
        guard dayHeight > 0.0 else {
            return
        }
        
        /// 当前周（页面第一天所在周）所在行背景
        let currentWeekRow = (firstColumn + firstDay.day - 1) / 7
        if currentWeekRow >= 0, currentWeekRow < rowsCount {
            let rowRect = CGRect(x: contentFrame.minX,
                                 y: dateAreaTop + CGFloat(currentWeekRow) * dayHeight,
                                 width: contentFrame.width,
                                 height: dayHeight)
            let rowPath = UIBezierPath(roundedRect: rowRect, cornerRadius: config.currentWeekCornerRadius)
            config.currentWeekColor.setFill()
            rowPath.fill()
        }
        
        /// 日期（当月 + 上月末 + 下月初，相邻月份透明度降低）
        let dayFontSize = scaledFontSize(by: min(dayWidth, dayHeight), ratio: config.dayFontRatio)
        let dayFont = UIFont.systemFont(ofSize: dayFontSize, weight: .medium)
        let dayAttributes: [NSAttributedString.Key: Any] = [
            .font: dayFont,
            .foregroundColor: config.dayColor
        ]
        let weekendAttributes: [NSAttributedString.Key: Any] = [
            .font: dayFont,
            .foregroundColor: config.weekendColor
        ]
        let todayAttributes: [NSAttributedString.Key: Any] = [
            .font: dayFont,
            .foregroundColor: config.todayColor
        ]
        let adjacentDayAttributes: [NSAttributedString.Key: Any] = [
            .font: dayFont,
            .foregroundColor: config.dayColor.withAlphaComponent(config.adjacentAlpha)
        ]
        
        let today = Date()
        let containsToday = today.isInSameMonthAs(monthDate)
        let todayDay = today.day
        
        /// 上月末的天数（当月 1 号的前一天所在月份的天数）
        let previousMonthDaysCount = monthDate.dateByAddingDays(-1)?.numberOfDaysInMonth() ?? 0
        
        for position in 0..<(rowsCount * 7) {
            let column = position % 7
            let row = position / 7
            
            /// 该位置对应的天以及是否属于当月
            let day: Int
            let isCurrentMonth: Bool
            if position < firstColumn {
                /// 上月末
                day = previousMonthDaysCount - firstColumn + position + 1
                isCurrentMonth = false
            } else if position < firstColumn + daysCount {
                /// 当月
                day = position - firstColumn + 1
                isCurrentMonth = true
            } else {
                /// 下月初
                day = position - firstColumn - daysCount + 1
                isCurrentMonth = false
            }
            
            let cellX = contentFrame.minX + CGFloat(column) * dayWidth
            let cellY = dateAreaTop + CGFloat(row) * dayHeight
            
            let dayString = "\(day)"
            let isToday = isCurrentMonth && containsToday && day == todayDay
            let attributes: [NSAttributedString.Key: Any]
            if isToday {
                attributes = todayAttributes
            } else if isWeekend(column: column) {
                /// 周末本身颜色已较浅，相邻月份不再叠加透明度
                attributes = weekendAttributes
            } else {
                attributes = isCurrentMonth ? dayAttributes : adjacentDayAttributes
            }
            
            let daySize = dayString.size(withAttributes: attributes)
            let dayPoint = CGPoint(x: cellX + (dayWidth - daySize.width) / 2.0,
                                   y: cellY + (dayHeight - daySize.height) / 2.0)
            
            dayString.draw(at: dayPoint, withAttributes: attributes)
        }
    }
    
    // MARK: - Helpers
    
    /// 字号：按可用尺寸自适应
    private func scaledFontSize(by size: CGFloat, ratio: CGFloat) -> CGFloat {
        return min(config.maximumFontSize, max(config.minimumFontSize, size * ratio))
    }
    
    /// 该列是否周末
    private func isWeekend(column: Int) -> Bool {
        let weekday = (column + firstWeekday.rawValue - 1) % 7 + 1
        return weekday == 1 || weekday == 7
    }
}

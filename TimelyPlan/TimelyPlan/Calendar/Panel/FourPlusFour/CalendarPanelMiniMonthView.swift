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
    
    /// 点击日期
    var didSelectDate: ((Date) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = true
        /// 尺寸变化时重新绘制，避免复用旧的绘制内容
        contentMode = .redraw
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 手势
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let layout = makeLayout(),
              let position = layout.position(at: gesture.location(in: self)),
              let date = layout.date(at: position) else {
            return
        }
        
        didSelectDate?(date)
    }
    
    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        guard let layout = makeLayout() else {
            return
        }
        
        /// 星期
        if config.showsWeekdaySymbols {
            let weekdayAttributes: [NSAttributedString.Key: Any] = [
                .font: layout.weekdayFont,
                .foregroundColor: config.weekdayColor
            ]
            let weekdays = Date.veryShortWeekdaySymbols(firstWeekday: firstWeekday.rawValue)
            for (index, weekday) in weekdays.enumerated() {
                let weekdaySize = weekday.size(withAttributes: weekdayAttributes)
                let x = layout.contentFrame.minX + CGFloat(index) * layout.dayWidth + (layout.dayWidth - weekdaySize.width) / 2.0
                weekday.draw(at: CGPoint(x: x, y: layout.contentFrame.minY), withAttributes: weekdayAttributes)
            }
        }
        
        /// 当前周（页面第一天所在周）所在行背景
        if let firstDay = firstDay, let position = layout.position(of: firstDay) {
            let rowRect = layout.frame(row: position / 7)
            let rowPath = UIBezierPath(roundedRect: rowRect, cornerRadius: config.currentWeekCornerRadius)
            config.currentWeekColor.setFill()
            rowPath.fill()
        }
        
        /// 日期（当月 + 上月末 + 下月初，相邻月份透明度降低）
        let dayAttributes: [NSAttributedString.Key: Any] = [
            .font: layout.dayFont,
            .foregroundColor: config.dayColor
        ]
        let weekendAttributes: [NSAttributedString.Key: Any] = [
            .font: layout.dayFont,
            .foregroundColor: config.weekendColor
        ]
        let todayAttributes: [NSAttributedString.Key: Any] = [
            .font: layout.dayFont,
            .foregroundColor: config.todayColor
        ]
        let adjacentDayAttributes: [NSAttributedString.Key: Any] = [
            .font: layout.dayFont,
            .foregroundColor: config.dayColor.withAlphaComponent(config.adjacentAlpha)
        ]
        
        let today = Date()
        let containsToday = today.isInSameMonthAs(layout.monthDate)
        let todayDay = today.day
        /// 上月末的天数（当月 1 号的前一天所在月份的天数）
        let previousMonthDaysCount = layout.monthDate.dateByAddingDays(-1)?.numberOfDaysInMonth() ?? 0
        
        for position in 0..<layout.numberOfCells {
            let cellFrame = layout.frame(at: position)
            
            /// 该位置对应的天以及是否属于当月
            let day: Int
            let isCurrentMonth: Bool
            if position < layout.firstColumn {
                /// 上月末
                day = previousMonthDaysCount - layout.firstColumn + position + 1
                isCurrentMonth = false
            } else if position < layout.firstColumn + layout.daysCount {
                /// 当月
                day = position - layout.firstColumn + 1
                isCurrentMonth = true
            } else {
                /// 下月初
                day = position - layout.firstColumn - layout.daysCount + 1
                isCurrentMonth = false
            }
            
            let dayString = "\(day)"
            let isToday = isCurrentMonth && containsToday && day == todayDay
            let attributes: [NSAttributedString.Key: Any]
            if isToday {
                attributes = todayAttributes
            } else if isWeekend(column: position % 7) {
                /// 周末本身颜色已较浅，相邻月份不再叠加透明度
                attributes = weekendAttributes
            } else {
                attributes = isCurrentMonth ? dayAttributes : adjacentDayAttributes
            }
            
            let daySize = dayString.size(withAttributes: attributes)
            let dayPoint = CGPoint(x: cellFrame.minX + (cellFrame.width - daySize.width) / 2.0,
                                   y: cellFrame.minY + (cellFrame.height - daySize.height) / 2.0)
            
            dayString.draw(at: dayPoint, withAttributes: attributes)
        }
    }
    
    // MARK: - Layout
    
    /// 绘制与点击共用的布局信息
    private struct Layout {
        
        /// 显示月份
        let monthDate: Date
        
        /// 网格第一个格子的日期
        let firstDate: Date
        
        /// 当月 1 号在网格中的列（从 0 开始）
        let firstColumn: Int
        
        /// 当月天数
        let daysCount: Int
        
        /// 网格行数
        let rowsCount: Int
        
        /// 内容区域（边间距内）
        let contentFrame: CGRect
        
        /// 单格宽度
        let dayWidth: CGFloat
        
        /// 日期区域顶部（星期行下方）
        let dateAreaTop: CGFloat
        
        /// 单格高度
        let dayHeight: CGFloat
        
        let weekdayFont: UIFont
        let dayFont: UIFont
        
        var numberOfCells: Int {
            return rowsCount * 7
        }
        
        /// 位置对应的日期
        func date(at position: Int) -> Date? {
            return firstDate.dateByAddingDays(position)
        }
        
        /// 日期对应的位置
        func position(of date: Date) -> Int? {
            let position = Date.days(fromDate: firstDate, toDate: date)
            guard position >= 0, position < numberOfCells else {
                return nil
            }
            
            return position
        }
        
        /// 位置对应的 frame
        func frame(at position: Int) -> CGRect {
            let column = position % 7
            let row = position / 7
            return CGRect(x: contentFrame.minX + CGFloat(column) * dayWidth,
                          y: dateAreaTop + CGFloat(row) * dayHeight,
                          width: dayWidth,
                          height: dayHeight)
        }
        
        /// 行对应的 frame（整行）
        func frame(row: Int) -> CGRect {
            return CGRect(x: contentFrame.minX,
                          y: dateAreaTop + CGFloat(row) * dayHeight,
                          width: contentFrame.width,
                          height: dayHeight)
        }
        
        /// 点击位置对应的位置索引
        func position(at point: CGPoint) -> Int? {
            guard dayWidth > 0.0, dayHeight > 0.0, point.y >= dateAreaTop else {
                return nil
            }
            
            let column = Int((point.x - contentFrame.minX) / dayWidth)
            let row = Int((point.y - dateAreaTop) / dayHeight)
            guard (0..<7).contains(column), (0..<rowsCount).contains(row) else {
                return nil
            }
            
            return row * 7 + column
        }
    }
    
    private func makeLayout() -> Layout? {
        guard let firstDay = firstDay, bounds.width > 0.0, bounds.height > 0.0 else {
            return nil
        }
        
        let monthDate = firstDay.startOfMonth()
        let daysCount = monthDate.numberOfDaysInMonth()
        guard daysCount > 0 else {
            return nil
        }
        
        let firstColumn = (monthDate.weekday - firstWeekday.rawValue + 7) % 7
        let rowsCount = Int(ceil(Double(firstColumn + daysCount) / 7.0))
        guard rowsCount > 0 else {
            return nil
        }
        
        let contentFrame = bounds.inset(by: config.padding)
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return nil
        }
        
        let dayWidth = contentFrame.width / 7.0
        let weekdayFont = UIFont.boldSystemFont(ofSize: config.weekdayFontSize)
        
        var dateAreaTop = contentFrame.minY
        if config.showsWeekdaySymbols {
            dateAreaTop += ceil(weekdayFont.lineHeight) + config.weekdaySpacing
        }
        
        let dayHeight = (contentFrame.maxY - dateAreaTop) / CGFloat(rowsCount)
        guard dayHeight > 0.0 else {
            return nil
        }
        
        let dayFont = UIFont.systemFont(ofSize: scaledFontSize(by: min(dayWidth, dayHeight), ratio: config.dayFontRatio),
                                        weight: .medium)
        
        return Layout(monthDate: monthDate,
                      firstDate: monthDate.firstDayOfWeek(firstWeekday: firstWeekday),
                      firstColumn: firstColumn,
                      daysCount: daysCount,
                      rowsCount: rowsCount,
                      contentFrame: contentFrame,
                      dayWidth: dayWidth,
                      dateAreaTop: dateAreaTop,
                      dayHeight: dayHeight,
                      weekdayFont: weekdayFont,
                      dayFont: dayFont)
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

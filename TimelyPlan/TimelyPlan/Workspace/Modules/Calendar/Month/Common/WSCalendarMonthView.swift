//
//  WSCalendarMonthView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 外观

/// 月历配色，随浅色 / 深色模式切换
enum WSCalendarMonthAppearance {

    /// 背景色。深色模式沿用日历日期组件的深色底
    static let backColor = Color(light: 0xFFFFFF, dark: 0x17171A)

    static let titleColor = Color(light: 0x232323, dark: 0xFFFFFF)
    static let weekdayColor = Color(0x8E8E93)
    static let dayColor = Color(light: 0x232323, dark: 0xFFFFFF)
    static let weekendColor = Color(light: 0xB0B0B5, dark: 0x8E8E93)
    static let adjacentDayColor = Color(light: 0x232323, 0.3, dark: 0xFFFFFF, 0.28)

    /// 今天的圆圈与文字颜色
    static let todayBackColor = Color(0xE8362C)
    static let todayTextColor = UIColor.white

    /// 事项圆点的描边色，与背景一致才能分开重叠的圆点
    static let eventDotBorderColor = backColor
}

/// 单月月历的外观。字号按单元格尺寸自适应。
struct WSCalendarMonthViewAppearance {

    var backgroundColor = WSCalendarMonthAppearance.backColor
    var titleColor = WSCalendarMonthAppearance.titleColor
    var weekdayColor = WSCalendarMonthAppearance.weekdayColor
    var dayColor = WSCalendarMonthAppearance.dayColor
    var weekendColor = WSCalendarMonthAppearance.weekendColor
    var adjacentDayColor = WSCalendarMonthAppearance.adjacentDayColor
    var todayBackgroundColor = WSCalendarMonthAppearance.todayBackColor
    var todayTextColor = WSCalendarMonthAppearance.todayTextColor

    /// 字号相对单元格宽度的比例
    var titleFontRatio: CGFloat = 0.60
    var weekdayFontRatio: CGFloat = 0.42
    var dayFontRatio: CGFloat = 0.52

    /// 标题、星期头与日期区域的间距
    var titleSpacing: CGFloat = 1.5
    var weekdaySpacing: CGFloat = 1.5
}

// MARK: - 月历视图

/// 单月月历视图。
///
/// 只绘制标题、星期头与日期，在一次 `draw` 中完成，只有一层 CALayer；
/// 事项指示由独立的 `WSCalendarMonthEventIndicatorView` 叠放绘制。
class WSCalendarMonthView: UIView {

    /// 外观
    var appearance = WSCalendarMonthViewAppearance() {
        didSet {
            backgroundColor = appearance.backgroundColor
            invalidateGrid()
        }
    }

    /// 展示的月份，取该月 1 号
    var monthDate: Date? {
        didSet {
            /// 月份符号由 DateFormatter 提供，只在月份变化时取一次
            defaultTitle = monthDate.map { Date.shortMonthSymbol(ofMonth: $0.month) } ?? ""
            invalidateGrid()
        }
    }

    /// 周开始日，1 = 周日
    var firstWeekday: Int = 1 {
        didSet {
            guard firstWeekday != oldValue else {
                return
            }

            invalidateGrid()
        }
    }

    /// 今天，用于高亮当天
    var today: Date = Date() {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 是否绘制上月与下月的日期
    var showsAdjacentDays: Bool = true {
        didSet {
            guard showsAdjacentDays != oldValue else {
                return
            }

            setNeedsDisplay()
        }
    }

    /// 最小行数。多个月份并排时统一行数，日期才能左右对齐；0 表示按当月周数自适应
    var minimumRowCount: Int = 0 {
        didSet {
            guard minimumRowCount != oldValue else {
                return
            }

            invalidateGrid()
        }
    }

    /// 当月占用的周数
    var requiredRowCount: Int {
        guard let monthDate = monthDate else {
            return 0
        }

        let monthStart = monthDate.startOfMonth()
        let firstColumn = (monthStart.weekday - firstWeekday + 7) % 7
        return Int(ceil(Double(firstColumn + monthStart.numberOfDaysInMonth()) / 7.0))
    }

    /// 标题文案，默认取月份的短名称
    var titleText: String? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 点击某天
    var didSelectDate: ((Date) -> Void)?

    /// 绘制与点击共用的网格信息
    private struct Grid {

        let monthStart: Date

        /// 网格第一格对应的日期
        let firstDate: Date

        /// 当月 1 号在网格中的列
        let firstColumn: Int

        /// 当月天数
        let daysCount: Int

        /// 网格行数，按当月占用的周数自适应
        let rowsCount: Int

        /// 上月天数，用于绘制相邻月份的天
        let previousMonthDaysCount: Int

        /// 内容区域（边距内）
        let contentFrame: CGRect

        let cellWidth: CGFloat
        let cellHeight: CGFloat

        /// 日期区域顶部（星期头下方）
        let dateAreaTop: CGFloat

        let titleHeight: CGFloat
        let weekdayHeight: CGFloat

        let titleFont: UIFont
        let weekdayFont: UIFont
        let dayFont: UIFont

        var numberOfCells: Int {
            return rowsCount * 7
        }

        func frame(at position: Int) -> CGRect {
            let column = position % 7
            let row = position / 7
            return CGRect(x: contentFrame.minX + CGFloat(column) * cellWidth,
                          y: dateAreaTop + CGFloat(row) * cellHeight,
                          width: cellWidth,
                          height: cellHeight)
        }

        func date(at position: Int) -> Date? {
            return firstDate.dateByAddingDays(position)
        }

        func position(at point: CGPoint) -> Int? {
            guard cellWidth > 0.0, cellHeight > 0.0, point.y >= dateAreaTop else {
                return nil
            }

            let column = Int((point.x - contentFrame.minX) / cellWidth)
            let row = Int((point.y - dateAreaTop) / cellHeight)
            guard (0..<7).contains(column), (0..<rowsCount).contains(row) else {
                return nil
            }

            return row * 7 + column
        }
    }

    private var grid: Grid?

    /// 默认标题，取月份的短名称
    private var defaultTitle = ""

    private var appliedSize: CGSize = .zero

    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = appearance.backgroundColor
        isOpaque = true
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard appliedSize != bounds.size else {
            return
        }

        appliedSize = bounds.size
        invalidateGrid()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }

        /// 绘制用的颜色已按旧的模式解析，切换浅色 / 深色后需要重绘
        setNeedsDisplay()
    }

    // MARK: - 交互

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let grid = makeGrid(),
              let position = grid.position(at: gesture.location(in: self)),
              let date = grid.date(at: position) else {
            return
        }

        didSelectDate?(date)
    }

    // MARK: - 绘制

    override func draw(_ rect: CGRect) {
        guard let grid = makeGrid(), let context = UIGraphicsGetCurrentContext() else {
            return
        }

        drawTitle(in: grid)
        drawWeekdays(in: grid)
        drawDays(in: grid, context: context)
    }

    private func drawTitle(in grid: Grid) {
        let title = titleText ?? defaultTitle
        let attributes: [NSAttributedString.Key: Any] = [
            .font: grid.titleFont,
            .foregroundColor: appearance.titleColor
        ]

        let size = title.size(withAttributes: attributes)
        let point = CGPoint(x: grid.contentFrame.midX - size.width / 2.0,
                            y: grid.contentFrame.minY + (grid.titleHeight - size.height) / 2.0)
        title.draw(at: point, withAttributes: attributes)
    }

    private func drawWeekdays(in grid: Grid) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: grid.weekdayFont,
            .foregroundColor: appearance.weekdayColor
        ]
        let top = grid.contentFrame.minY + grid.titleHeight + appearance.titleSpacing
        let weekdays = Date.veryShortWeekdaySymbols(firstWeekday: firstWeekday)

        for (index, weekday) in weekdays.enumerated() {
            let size = weekday.size(withAttributes: attributes)
            let point = CGPoint(x: grid.contentFrame.minX + CGFloat(index) * grid.cellWidth + (grid.cellWidth - size.width) / 2.0,
                                y: top + (grid.weekdayHeight - size.height) / 2.0)
            weekday.draw(at: point, withAttributes: attributes)
        }
    }

    private func drawDays(in grid: Grid, context: CGContext) {
        let dayAttributes: [NSAttributedString.Key: Any] = [
            .font: grid.dayFont,
            .foregroundColor: appearance.dayColor
        ]
        let weekendAttributes: [NSAttributedString.Key: Any] = [
            .font: grid.dayFont,
            .foregroundColor: appearance.weekendColor
        ]
        let adjacentDayAttributes: [NSAttributedString.Key: Any] = [
            .font: grid.dayFont,
            .foregroundColor: appearance.adjacentDayColor
        ]
        let todayAttributes: [NSAttributedString.Key: Any] = [
            .font: grid.dayFont,
            .foregroundColor: appearance.todayTextColor
        ]

        let todayDay = grid.monthStart.isInSameMonthAs(today) ? today.day : 0

        for position in 0..<grid.numberOfCells {
            let cellFrame = grid.frame(at: position)

            let day: Int
            let isCurrentMonth: Bool
            if position < grid.firstColumn {
                day = grid.previousMonthDaysCount - grid.firstColumn + position + 1
                isCurrentMonth = false
            } else if position < grid.firstColumn + grid.daysCount {
                day = position - grid.firstColumn + 1
                isCurrentMonth = true
            } else {
                day = position - grid.firstColumn - grid.daysCount + 1
                isCurrentMonth = false
            }

            guard day >= 1 else {
                continue
            }

            /// 相邻月份只绘制当月时跳过，网格位置保留
            guard isCurrentMonth || showsAdjacentDays else {
                continue
            }

            let isToday = isCurrentMonth && day == todayDay

            let attributes: [NSAttributedString.Key: Any]
            if isToday {
                attributes = todayAttributes
            } else if !isCurrentMonth {
                attributes = adjacentDayAttributes
            } else if Self.isWeekend(column: position % 7, firstWeekday: firstWeekday) {
                attributes = weekendAttributes
            } else {
                attributes = dayAttributes
            }

            let dayString = "\(day)"
            let daySize = dayString.size(withAttributes: attributes)

            /// 日期始终垂直居中，同一行的天保持水平对齐
            let centerY = cellFrame.midY

            if isToday {
                let diameter = min(grid.cellWidth, grid.cellHeight) * 0.78
                let circleRect = CGRect(x: cellFrame.midX - diameter / 2.0,
                                        y: centerY - diameter / 2.0,
                                        width: diameter,
                                        height: diameter)
                context.setFillColor(appearance.todayBackgroundColor.cgColor)
                context.fillEllipse(in: circleRect)
            }

            let point = CGPoint(x: cellFrame.midX - daySize.width / 2.0,
                                y: centerY - daySize.height / 2.0)
            dayString.draw(at: point, withAttributes: attributes)
        }
    }

    // MARK: - 网格

    private func makeGrid() -> Grid? {
        if let grid = grid {
            return grid
        }

        guard let monthDate = monthDate else {
            return nil
        }

        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return nil
        }

        let monthStart = monthDate.startOfMonth()
        let daysCount = monthStart.numberOfDaysInMonth()
        guard daysCount > 0 else {
            return nil
        }

        let firstColumn = (monthStart.weekday - firstWeekday + 7) % 7
        let previousMonthDaysCount = monthStart.dateByAddingDays(-1)?.numberOfDaysInMonth() ?? 0
        let firstDate = monthStart.dateByAddingDays(-firstColumn) ?? monthStart
        let rowsCount = max(minimumRowCount, Int(ceil(Double(firstColumn + daysCount) / 7.0)))

        let cellWidth = contentFrame.width / 7.0
        let titleFont = UIFont.systemFont(ofSize: cellWidth * appearance.titleFontRatio, weight: .medium)
        let weekdayFont = UIFont.systemFont(ofSize: cellWidth * appearance.weekdayFontRatio, weight: .medium)
        let titleHeight = ceil(titleFont.lineHeight)
        let weekdayHeight = ceil(weekdayFont.lineHeight)

        let dateAreaTop = contentFrame.minY + titleHeight + appearance.titleSpacing
            + weekdayHeight + appearance.weekdaySpacing
        let cellHeight = max((contentFrame.maxY - dateAreaTop) / CGFloat(max(rowsCount, 1)), 1.0)

        let dayFontSize = max(min(cellWidth * appearance.dayFontRatio, cellHeight * 0.62), 5.0)
        let dayFont = UIFont.systemFont(ofSize: dayFontSize)

        let grid = Grid(monthStart: monthStart,
                        firstDate: firstDate,
                        firstColumn: firstColumn,
                        daysCount: daysCount,
                        rowsCount: rowsCount,
                        previousMonthDaysCount: previousMonthDaysCount,
                        contentFrame: contentFrame,
                        cellWidth: cellWidth,
                        cellHeight: cellHeight,
                        dateAreaTop: dateAreaTop,
                        titleHeight: titleHeight,
                        weekdayHeight: weekdayHeight,
                        titleFont: titleFont,
                        weekdayFont: weekdayFont,
                        dayFont: dayFont)
        self.grid = grid
        return grid
    }

    /// 指定天所在单元格的位置，供事项指示层对齐绘制
    func frame(forDay day: Int) -> CGRect? {
        guard let grid = makeGrid(), day >= 1, day <= grid.daysCount else {
            return nil
        }

        return grid.frame(at: grid.firstColumn + day - 1)
    }

    private func invalidateGrid() {
        grid = nil
        setNeedsDisplay()
    }

    /// 该列是否周末
    private static func isWeekend(column: Int, firstWeekday: Int) -> Bool {
        let weekday = (column + firstWeekday - 1) % 7 + 1
        return weekday == 1 || weekday == 7
    }
}

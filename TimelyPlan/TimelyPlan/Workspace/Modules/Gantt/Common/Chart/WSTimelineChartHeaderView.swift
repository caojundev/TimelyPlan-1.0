//
//  WSTimelineChartHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的顶部刻度视图
///
/// 组件不滚动，刻度直接从左向右按范围依次绘制，宽度按刻度数量等分。
final class WSTimelineChartHeaderView: UIView {

    /// 当前展示的时间范围
    var timeRange: WSTimelineChartTimeRange? {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    /// 主标题与副标题之间的间距
    private let titleValueSpacing: CGFloat = 2.0

    private let weekdayFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
    private let dayFont = UIFont.boldSystemFont(ofSize: 13.0)
    private let unitFont = UIFont.boldSystemFont(ofSize: 13.0)
    private let subFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)

    /// 刻度分隔线与上下分隔线
    private let separatorLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = WSTimelineChartConfig.headerBackgroundColor
        clipsToBounds = true
        contentMode = .redraw

        separatorLayer.fillColor = nil
        separatorLayer.lineWidth = 1.0
        separatorLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(separatorLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateSeparatorLayer()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }

        setNeedsLayout()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let timeRange = timeRange,
              let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let units = timeRange.headerUnits(width: bounds.width)
        guard !units.isEmpty else { return }

        context.saveGState()
        context.clip(to: bounds)

        for unit in units {
            draw(unit: unit, scale: timeRange.scale)
        }

        context.restoreGState()
    }

    // MARK: - 分割线

    /// 统一用一条路径绘制所有竖线与上下横线
    private func updateSeparatorLayer() {
        separatorLayer.frame = bounds
        separatorLayer.strokeColor = WSTimelineChartConfig.separatorColor
            .resolvedColor(with: traitCollection)
            .cgColor

        guard let timeRange = timeRange, bounds.width > 0.0 else {
            separatorLayer.path = nil
            return
        }

        let units = timeRange.headerUnits(width: bounds.width)
        guard !units.isEmpty else {
            separatorLayer.path = nil
            return
        }

        let path = CGMutablePath()
        for unit in units {
            guard unit.minX > 0.0, unit.minX < bounds.width else { continue }

            path.move(to: CGPoint(x: unit.minX + 0.5, y: 0.0))
            path.addLine(to: CGPoint(x: unit.minX + 0.5, y: bounds.height))
        }

        /// 最后一个刻度的右边界
        if let last = units.last {
            let right = last.minX + last.width
            if right > 0.0, right < bounds.width {
                path.move(to: CGPoint(x: right + 0.5, y: 0.0))
                path.addLine(to: CGPoint(x: right + 0.5, y: bounds.height))
            }
        }

        path.move(to: CGPoint(x: 0.0, y: 0.5))
        path.addLine(to: CGPoint(x: bounds.width, y: 0.5))

        path.move(to: CGPoint(x: 0.0, y: bounds.height - 0.5))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 0.5))

        separatorLayer.path = path
    }

    // MARK: - 刻度绘制

    private func draw(unit: WSTimelineChartTimeRange.Unit, scale: GanttTimeScale.Scale) {
        /// 左右留出等宽间距，文本以刻度中心水平居中
        let contentX = unit.minX + 8.0
        let contentWidth = unit.width - 16.0
        guard contentWidth > 0.0 else { return }

        let date = unit.date
        let primaryTextColor: UIColor = unit.containsToday ? .primary : Color(light: 0x232323,
                                                                            dark: 0xf0f0f0)
        let secondaryTextColor: UIColor = unit.containsToday ? .primary : .secondaryLabel

        switch scale {
        case .day:
            let isMonthStart = Calendar.current.component(.day, from: date) == 1
            let title = isMonthStart ? date.shortMonthSymbol : date.weekdaySymbol(style: .short)
            let titleHeight = weekdayFont.lineHeight
            let valueHeight = dayFont.lineHeight
            let startY = (bounds.height - titleHeight - valueHeight - titleValueSpacing) / 2.0

            drawText(title,
                     font: weekdayFont,
                     color: secondaryTextColor,
                     frame: CGRect(x: contentX, y: startY, width: contentWidth, height: titleHeight))
            drawText("\(date.day)",
                     font: dayFont,
                     color: primaryTextColor,
                     frame: CGRect(x: contentX, y: startY + titleHeight + titleValueSpacing, width: contentWidth, height: valueHeight))

        case .week:
            let weekNumber = Calendar.weekNumber(for: date, firstWeekday: GanttSetting.shared.firstWeekday)
            let titleHeight = weekdayFont.lineHeight
            let valueHeight = dayFont.lineHeight
            let startY = (bounds.height - titleHeight - valueHeight - titleValueSpacing) / 2.0

            drawText(String(format: resGetString("W%ld"), weekNumber),
                     font: weekdayFont,
                     color: secondaryTextColor,
                     frame: CGRect(x: contentX, y: startY, width: contentWidth, height: titleHeight))
            drawText(date.slashFormattedMonthDayString,
                     font: dayFont,
                     color: primaryTextColor,
                     frame: CGRect(x: contentX, y: startY + titleHeight + titleValueSpacing, width: contentWidth, height: valueHeight))

        case .month:
            let titleHeight = unitFont.lineHeight
            let valueHeight = subFont.lineHeight
            let startY = (bounds.height - titleHeight - valueHeight - titleValueSpacing) / 2.0

            drawText(date.shortMonthSymbol,
                     font: unitFont,
                     color: primaryTextColor,
                     frame: CGRect(x: contentX, y: startY, width: contentWidth, height: titleHeight))
            let endDate = date.endOfMonth()
            drawText("\(date.day)-\(endDate.day)",
                     font: subFont,
                     color: secondaryTextColor,
                     frame: CGRect(x: contentX, y: startY + titleHeight + titleValueSpacing, width: contentWidth, height: valueHeight))
        }
    }

    private func drawText(_ text: String,
                          font: UIFont,
                          color: UIColor,
                          frame rect: CGRect) {
        guard rect.width > 0.0 else { return }

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        paragraph.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]

        let textHeight = (text as NSString).size(withAttributes: [.font: font]).height
        let drawRect = CGRect(x: rect.minX,
                              y: rect.midY - textHeight / 2.0,
                              width: rect.width,
                              height: textHeight)
        (text as NSString).draw(in: drawRect, withAttributes: attributes)
    }
}

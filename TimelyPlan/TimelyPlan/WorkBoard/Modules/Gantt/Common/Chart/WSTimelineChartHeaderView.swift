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
/// 组件尺寸有限，只绘制可视范围内的刻度，且不响应滚动，由甘特图同步水平偏移。
final class WSTimelineChartHeaderView: UIView {

    /// 当前时间刻度
    var timeScale: GanttTimeScale? {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    /// 与甘特图同步的水平偏移
    var contentOffsetX: CGFloat = 0.0 {
        didSet {
            guard contentOffsetX != oldValue else { return }
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

    /// 刻度分隔线与底部分隔线
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
        guard let timeScale = timeScale,
              let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let unitWidth = WSTimelineChartConfig.pixelsPerUnit(for: timeScale.scale)
        let unitCount = WSTimelineChartGeometry.unitCount(timeScale: timeScale)
        guard unitWidth > 0, unitCount > 0 else { return }

        let visibleWidth = bounds.width
        let firstIndex = min(max(0, Int(floor(contentOffsetX / unitWidth))), unitCount - 1)
        let lastIndex = min(unitCount - 1, Int(ceil((contentOffsetX + visibleWidth) / unitWidth)))
        guard firstIndex <= lastIndex else { return }

        context.saveGState()
        context.clip(to: CGRect(x: 0.0, y: 0.0, width: visibleWidth, height: bounds.height))

        for index in firstIndex...lastIndex {
            let x = CGFloat(index) * unitWidth - contentOffsetX
            guard x < visibleWidth, x + unitWidth > 0 else { continue }

            let date = WSTimelineChartGeometry.unitStartDate(at: index, timeScale: timeScale)
            drawUnit(at: x, width: unitWidth, date: date, scale: timeScale.scale, isLast: index == unitCount - 1)
        }

        context.restoreGState()
    }

    // MARK: - 分割线

    /// 统一用一条路径绘制所有竖线与底部横线
    private func updateSeparatorLayer() {
        separatorLayer.frame = bounds
        separatorLayer.strokeColor = WSTimelineChartConfig.separatorColor
            .resolvedColor(with: traitCollection)
            .cgColor

        guard let timeScale = timeScale, bounds.width > 0.0 else {
            separatorLayer.path = nil
            return
        }

        let unitWidth = WSTimelineChartConfig.pixelsPerUnit(for: timeScale.scale)
        let unitCount = WSTimelineChartGeometry.unitCount(timeScale: timeScale)
        guard unitWidth > 0, unitCount > 0 else {
            separatorLayer.path = nil
            return
        }

        let visibleWidth = bounds.width
        let firstIndex = min(max(0, Int(floor(contentOffsetX / unitWidth))), unitCount - 1)
        let lastIndex = min(unitCount - 1, Int(ceil((contentOffsetX + visibleWidth) / unitWidth)))

        let path = CGMutablePath()

        if firstIndex <= lastIndex {
            for index in firstIndex...lastIndex {
                let x = CGFloat(index) * unitWidth - contentOffsetX
                guard x >= 0.0, x < visibleWidth else { continue }

                path.move(to: CGPoint(x: x + 0.5, y: 0.0))
                path.addLine(to: CGPoint(x: x + 0.5, y: bounds.height))
            }
        }

        path.move(to: CGPoint(x: 0.0, y: 0.5))
        path.addLine(to: CGPoint(x: bounds.width, y: 0.5))

        path.move(to: CGPoint(x: 0.0, y: bounds.height - 0.5))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 0.5))

        separatorLayer.path = path
    }

    // MARK: - 刻度绘制

    private func drawUnit(at x: CGFloat, width: CGFloat, date: Date, scale: GanttTimeScale.Scale, isLast: Bool) {
        let contentX = x + 12.0
        let contentWidth = width - 16.0
        let primaryTextColor: UIColor = date.isToday ? .primary : Color(light: 0x232323,
                                                                        dark: 0xf0f0f0)
        let secondaryTextColor: UIColor = date.isToday ? .primary : .secondaryLabel
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
        paragraph.alignment = .left
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

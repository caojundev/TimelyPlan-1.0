//
//  WSCalendarTimelineRulerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

// MARK: - 外观

/// 时间线刻度配色，随浅色 / 深色模式切换
struct WSCalendarTimelineRulerAppearance {

    var backgroundColor = Color(light: 0xFFFFFF, dark: 0x17171A)
    var hourColor = Color(light: 0x565656, dark: 0x9A9A9F)
    var separatorColor = Color(light: 0x666666, 0.02, dark: 0xaaaaaa, 0.02)
    var hourFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
}

// MARK: - 刻度视图

/// 日历时间线的整点刻度。
///
/// 从 `startHour` 到 `endHour` 绘制整点标签与横线，标签与横线垂直居中对齐；
/// 内容在一次 `draw` 中完成，只有一层 CALayer。
class WSCalendarTimelineRulerView: UIView {

    var appearance = WSCalendarTimelineRulerAppearance() {
        didSet {
            updateBackground()
            setNeedsDisplay()
        }
    }

    /// 起始小时，取值 0...23
    var startHour: Int = 20 {
        didSet {
            guard startHour != oldValue else {
                return
            }

            setNeedsDisplay()
        }
    }

    /// 结束小时。小于等于起始小时时按跨天处理，例如 20 到 0 即 20:00 到次日 00:00
    var endHour: Int = 24 {
        didSet {
            guard endHour != oldValue else {
                return
            }

            setNeedsDisplay()
        }
    }

    /// 每小时高度。小于等于 0 时按可用高度均分，正好填满视图
    var hourHeight: CGFloat = 0.0 {
        didSet {
            guard hourHeight != oldValue else {
                return
            }

            setNeedsDisplay()
        }
    }

    /// 时间标签所在列的宽度
    var hourLabelWidth: CGFloat = 40.0 {
        didSet {
            guard hourLabelWidth != oldValue else {
                return
            }

            setNeedsDisplay()
        }
    }

    /// 标签列与横线的间距
    var hourLabelSpacing: CGFloat = 6.0 {
        didSet {
            guard hourLabelSpacing != oldValue else {
                return
            }

            setNeedsDisplay()
        }
    }

    /// 刻度内容所需的高度
    var contentHeight: CGFloat {
        let hours = resolvedHours
        let height = resolvedHourHeight(in: layoutFrame())
        return padding.top + CGFloat(max(hours.end - hours.start, 0)) * height + padding.bottom
    }

    /// 刻度线所在的区域，事项视图据此与刻度线对齐
    var timelineFrame: CGRect {
        let frame = layoutFrame()
        let hours = resolvedHours
        let count = hours.end - hours.start
        guard count > 0 else {
            return .zero
        }

        let titles = makeHourTitles(from: hours.start, count: count)
        let attributes = hourAttributes()
        let left = frame.minX + labelColumnWidth(titles: titles, attributes: attributes) + hourLabelSpacing
        let height = CGFloat(count) * resolvedHourHeight(in: frame)
        return CGRect(x: left,
                      y: frame.minY,
                      width: max(frame.maxX - left, 0.0),
                      height: height)
    }

    /// 归一化后的小时范围，跨天时结束小时大于 24
    var resolvedHours: (start: Int, end: Int) {
        let start = min(max(startHour, 0), 23)
        var end = min(max(endHour, 0), 24)
        if end <= start {
            end += 24
        }

        return (start, end)
    }

    private var appliedSize: CGSize = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)

        padding = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 8.0)
        contentMode = .redraw
        updateBackground()
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
        setNeedsDisplay()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }

        setNeedsDisplay()
    }

    // MARK: - 绘制

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let frame = layoutFrame()
        let hours = resolvedHours
        let count = hours.end - hours.start
        guard frame.width > 0.0, frame.height > 0.0, count > 0 else {
            return
        }

        let titles = makeHourTitles(from: hours.start, count: count)
        let attributes = hourAttributes()
        let labelWidth = labelColumnWidth(titles: titles, attributes: attributes)
        let lineLeft = frame.minX + labelWidth + hourLabelSpacing
        let lineWidth = max(frame.maxX - lineLeft, 0.0)
        let scale = max(traitCollection.displayScale, 1.0)
        let lineHeight = 1.0 / scale
        let hourHeight = resolvedHourHeight(in: frame)

        context.setFillColor(appearance.separatorColor.resolvedColor(with: traitCollection).cgColor)

        for offset in 0...count {
            let centerY = frame.minY + CGFloat(offset) * hourHeight

            let title = titles[offset] as NSString
            let titleSize = title.size(withAttributes: attributes)
            title.draw(at: CGPoint(x: frame.minX + (labelWidth - titleSize.width) / 2.0,
                                   y: centerY - titleSize.height / 2.0),
                       withAttributes: attributes)

            /// 横线按屏幕像素对齐，避免发虚
            let lineTop = ((centerY - lineHeight / 2.0) * scale).rounded() / scale
            context.fill(CGRect(x: lineLeft, y: lineTop, width: lineWidth, height: lineHeight))
        }
    }

    private func resolvedHourHeight(in frame: CGRect) -> CGFloat {
        guard hourHeight <= 0.0 else {
            return hourHeight
        }

        let hours = resolvedHours
        return frame.height / CGFloat(max(hours.end - hours.start, 1))
    }

    private func hourAttributes() -> [NSAttributedString.Key: Any] {
        return [
            .font: appearance.hourFont,
            .foregroundColor: appearance.hourColor
        ]
    }

    /// 标签列宽度取配置值与实际文字宽度的较大者
    private func labelColumnWidth(titles: [String],
                                  attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        return max(hourLabelWidth, widestTitleWidth(titles, attributes: attributes))
    }

    /// 由整点生成标签，跨天小时后取 24 的余数
    private func makeHourTitles(from start: Int, count: Int) -> [String] {
        return (0...count).map { offset in
            return String(format: "%02d:00", (start + offset) % 24)
        }
    }

    private func widestTitleWidth(_ titles: [String],
                                  attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        return titles.reduce(0.0) { max($0, ($1 as NSString).size(withAttributes: attributes).width) }
    }

    private func updateBackground() {
        backgroundColor = appearance.backgroundColor
        isOpaque = appearance.backgroundColor.resolvedColor(with: traitCollection).cgColor.alpha >= 1.0
    }
}

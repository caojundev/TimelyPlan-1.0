//
//  WSWeekActivityView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

/// 一周活动视图。
///
/// 按天展示 7 根圆角柱条，柱条下方展示对应的文字；
/// 背景柱条保持满高，用于提示没有活动的日期。
class WSWeekActivityView: UIView {

    /// 每天的活动进度，取值为 0~1，按展示顺序排列
    var dailyActivity: [Float]? {
        didSet {
            setNeedsLayout()
        }
    }

    /// 第一天日期，用于推算每根柱条对应的文字
    var startDate: Date? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 需要强调的下标，强调的柱条只描边不展示背景。nil 表示不强调
    var highlightIndex: Int?

    /// 柱条间距
    var barSpacing: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 活动柱条颜色
    var progressColor: UIColor = Color(0x66D065) {
        didSet {
            activityLayer.fillColor = progressColor.cgColor
        }
    }

    /// 背景柱条颜色
    var trackColor: UIColor = Color(light: 0x000000, 0.06, dark: 0xFFFFFF, 0.10) {
        didSet {
            backLayer.fillColor = trackColor.cgColor
        }
    }

    /// 柱条下方文字字体
    var labelFont: UIFont = .systemFont(ofSize: 10.0) {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    /// 柱条下方文字颜色
    var labelColor: UIColor = .secondaryLabel {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 柱条下方文字，nil 时展示星期符号
    var labelText: ((Date) -> String)?

    /// 柱条与底部文字的间距
    var labelSpacing: CGFloat = 4.0 {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    /// 单根柱条的最小宽度
    var minimumBarWidth: CGFloat = 8.0

    /// 活动绘制图层
    private lazy var activityLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = progressColor.cgColor
        return layer
    }()

    /// 背景图层
    private lazy var backLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = trackColor.cgColor
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isOpaque = false
        self.contentMode = .redraw

        layer.addSublayer(backLayer)
        layer.addSublayer(activityLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = minimumBarWidth * CGFloat(DAYS_PER_WEEK)
            + barSpacing * CGFloat(DAYS_PER_WEEK - 1)
        let height = 60.0 + labelSpacing + ceil(labelFont.lineHeight)
        return CGSize(width: width + padding.horizontalLength, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backLayer.fillColor = trackColor.cgColor
        backLayer.frame = barFrame()
        activityLayer.fillColor = progressColor.cgColor
        activityLayer.frame = backLayer.frame
        updateBackLayer()
        updateActivityLayer()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let startDate = startDate else {
            return
        }

        let barsFrame = barFrame()
        let barWidth = barWidth(in: barsFrame.width)
        guard barWidth > 0.0 else {
            return
        }

        drawHighlight(in: barsFrame, barWidth: barWidth)

        let labelHeight = ceil(labelFont.lineHeight)
        let labelTop = barsFrame.maxY + labelSpacing

        for index in 0..<DAYS_PER_WEEK {
            guard let date = startDate.dateByAddingDays(index) else {
                continue
            }

            let isHighlighted = index == highlightIndex
            let attributes: [NSAttributedString.Key: Any] = [
                .font: labelFont,
                .foregroundColor: isHighlighted ? progressColor : labelColor
            ]

            let text = (labelText?(date) ?? date.veryShortWeekdaySymbol()) as NSString
            let textSize = text.size(withAttributes: attributes)
            let centerX = barsFrame.minX + originX(for: index, barWidth: barWidth) + barWidth / 2.0
            let textRect = CGRect(x: centerX - textSize.width / 2.0,
                                  y: labelTop + (labelHeight - textSize.height) / 2.0,
                                  width: textSize.width,
                                  height: textSize.height)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }

    /// 强调柱条的描边
    private func drawHighlight(in barsFrame: CGRect, barWidth: CGFloat) {
        let lineWidth = 1.5
        guard let highlightIndex = highlightIndex,
              highlightIndex >= 0, highlightIndex < DAYS_PER_WEEK,
              barWidth > lineWidth, barsFrame.height > lineWidth else {
            return
        }

        /// 描边向内收缩，避免线宽被裁切
        let rect = CGRect(x: barsFrame.minX + originX(for: highlightIndex, barWidth: barWidth) + lineWidth / 2.0,
                          y: barsFrame.minY + lineWidth / 2.0,
                          width: barWidth - lineWidth,
                          height: barsFrame.height - lineWidth)
        let path = UIBezierPath(roundedRect: rect,
                                cornerRadius: (barWidth - lineWidth) / 2.0)
        path.lineWidth = lineWidth
        progressColor.setStroke()
        path.stroke()
    }

    /// 柱条区域，底部预留文字的高度
    private func barFrame() -> CGRect {
        var frame = layoutFrame()
        frame.size.height = max(frame.height - labelSpacing - ceil(labelFont.lineHeight), 0.0)
        return frame
    }

    /// 背景柱条。强调的柱条改由描边呈现，不绘制背景
    private func updateBackLayer() {
        let bounds = backLayer.bounds
        let barWidth = barWidth(in: bounds.width)
        guard barWidth > 0.0, bounds.height > 0.0 else {
            backLayer.path = nil
            return
        }

        let path = UIBezierPath()
        for index in 0..<DAYS_PER_WEEK {
            if index == highlightIndex {
                continue
            }

            let rect = CGRect(x: originX(for: index, barWidth: barWidth),
                              y: 0.0,
                              width: barWidth,
                              height: bounds.height)
            path.append(UIBezierPath(roundedRect: rect, cornerRadius: barWidth / 2.0))
        }

        backLayer.path = path.cgPath
    }

    private func updateActivityLayer() {
        let bounds = activityLayer.bounds
        let barWidth = barWidth(in: bounds.width)
        guard barWidth > 0.0, bounds.height > 0.0 else {
            activityLayer.path = nil
            return
        }

        let path = UIBezierPath()
        for index in 0..<DAYS_PER_WEEK {
            guard let progress = dailyActivity?[safe: index], progress > 0 else {
                continue
            }

            /// 进度大于 0 时保证至少显示为圆点
            let height = max(validatedProgress(CGFloat(progress)) * bounds.height, barWidth)
            let rect = CGRect(x: originX(for: index, barWidth: barWidth),
                              y: bounds.height - height,
                              width: barWidth,
                              height: height)
            path.append(UIBezierPath(roundedRect: rect, cornerRadius: min(barWidth, height) / 2.0))
        }

        activityLayer.path = path.cgPath
    }

    private func barWidth(in width: CGFloat) -> CGFloat {
        let spacing = barSpacing * CGFloat(DAYS_PER_WEEK - 1)
        return max((width - spacing) / CGFloat(DAYS_PER_WEEK), 0.0)
    }

    private func originX(for index: Int, barWidth: CGFloat) -> CGFloat {
        return CGFloat(index) * (barWidth + barSpacing)
    }
}

//
//  WSCalendarMonthEventIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 月历事项指示层。
///
/// 与 `WSCalendarMonthView` 同尺寸叠放，只在有事项的天底部绘制圆点；
/// 日期绘制不感知事项，两者互不影响。
class WSCalendarMonthEventIndicatorView: UIView {

    /// 每天最多绘制的圆点数量
    private static let maximumDotCount = 3

    /// 圆点直径上限
    private static let maximumDotDiameter: CGFloat = 3.0

    /// 每天的事项指示颜色，key 为日
    var dayEventColors: [Int: [UIColor]] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 圆点描边色，与背景一致才能分开重叠的圆点
    var borderColor = WSCalendarMonthAppearance.eventDotBorderColor

    /// 提供日期网格的月历视图
    private weak var monthView: WSCalendarMonthView?

    private var appliedSize: CGSize = .zero

    init(monthView: WSCalendarMonthView) {
        self.monthView = monthView
        super.init(frame: .zero)

        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
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

    override func draw(_ rect: CGRect) {
        guard let monthView = monthView,
              let context = UIGraphicsGetCurrentContext(),
              !dayEventColors.isEmpty else {
            return
        }

        for (day, colors) in dayEventColors where !colors.isEmpty {
            guard var cellFrame = monthView.frame(forDay: day) else {
                continue
            }

            /// 指示层与月历视图同尺寸叠放，转换后坐标一致
            cellFrame = monthView.convert(cellFrame, to: self)
            drawDots(colors: colors, in: cellFrame, context: context)
        }
    }

    /// 在单元格底部绘制圆点，超过上限时只绘制前几个
    private func drawDots(colors: [UIColor], in cellFrame: CGRect, context: CGContext) {
        let dotDiameter = min(cellFrame.height * 0.16, Self.maximumDotDiameter)
        let dots = Array(colors.prefix(Self.maximumDotCount))
        let step = dotDiameter * 0.8
        let totalWidth = dotDiameter + CGFloat(dots.count - 1) * step
        let top = cellFrame.maxY - dotDiameter

        var left = cellFrame.midX - totalWidth / 2.0
        for color in dots {
            let dotRect = CGRect(x: left, y: top, width: dotDiameter, height: dotDiameter)
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: dotRect)

            /// 多个圆点时描边，重叠部分也能分辨
            if dots.count > 1 {
                context.setStrokeColor(borderColor.cgColor)
                context.setLineWidth(0.8)
                context.strokeEllipse(in: dotRect)
            }

            left += step
        }
    }
}

//
//  WSCalendarWeekEventBarWeekdayView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 周事项条的周符号行：一次绘制 7 个周符号，避免创建 7 个标签。
class WSCalendarWeekEventBarWeekdayView: UIView {

    /// 布局尺寸
    private enum Metrics {

        /// 周符号字号
        static let font = UIFont.systemFont(ofSize: 10.0, weight: .medium)

        /// 列宽放不下时的最小缩放比例
        static let minimumScale: CGFloat = 0.6
    }

    /// 文字居中的段落样式
    private let paragraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byClipping
        return paragraphStyle
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        /// 宽度变化后需要按新的列宽重新绘制
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }

        let symbols = Date.weekdaySymbols(style: .short,
                                          firstWeekday: CalendarSetting.shared.firstWeekday.rawValue)
        let itemWidth = bounds.width / CGFloat(max(symbols.count, 1))
        guard itemWidth > 0.0 else {
            return
        }

        for (index, symbol) in symbols.enumerated() {
            let font = fittedFont(for: symbol, maximumWidth: itemWidth)
            let textHeight = ceil(font.lineHeight)
            let textRect = CGRect(x: CGFloat(index) * itemWidth,
                                  y: (bounds.height - textHeight) / 2.0,
                                  width: itemWidth,
                                  height: textHeight)
            (symbol as NSString).draw(in: textRect,
                                      withAttributes: [.font: font,
                                                       .foregroundColor: UIColor.secondaryLabel,
                                                       .paragraphStyle: paragraphStyle])
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        /// 深浅色模式下文字颜色不同，需要重绘
        setNeedsDisplay()
    }

    /// 列宽放不下时等比缩小字号，避免文字超出所属的列
    private func fittedFont(for title: String, maximumWidth: CGFloat) -> UIFont {
        let font = Metrics.font
        let width = (title as NSString).size(withAttributes: [.font: font]).width
        guard width > maximumWidth else {
            return font
        }

        let scale = max(maximumWidth / width, Metrics.minimumScale)
        return font.withSize(font.pointSize * scale)
    }
}

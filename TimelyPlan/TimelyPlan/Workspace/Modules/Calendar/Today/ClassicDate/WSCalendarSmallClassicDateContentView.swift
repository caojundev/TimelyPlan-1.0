//
//  WSCalendarSmallClassicDateContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·经典日期：顶部红色月份横幅，中间大号日期，底部星期居中。
class WSCalendarSmallClassicDateContentView: WSCalendarSmallDateContentView {

    private enum Metrics {
        static let headerHeightRatio: CGFloat = 0.27
        static let dayCenterRatio: CGFloat = 0.51
        static let weekdayBottomRatio: CGFloat = 0.12
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        monthLabel.backgroundColor = WSCalendarSmallDateAppearance.accentColor
        /// 红色横幅上的文字固定为白色，浅色与深色模式都保持一致
        monthLabel.textColor = .white
        monthLabel.isOpaque = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局
    override func fontSizes(for contentSize: CGSize) -> (month: CGFloat, weekday: CGFloat, day: CGFloat) {
        let unit = min(contentSize.width, contentSize.height)
        return (unit * 0.14, unit * 0.11, unit * 0.50)
    }

    override func layoutDateLabels(in contentFrame: CGRect) {
        monthLabel.size = CGSize(width: contentFrame.width,
                                 height: contentFrame.height * Metrics.headerHeightRatio)
        monthLabel.left = contentFrame.minX
        monthLabel.top = contentFrame.minY

        dayLabel.size = CGSize(width: contentFrame.width, height: ceil(dayLabel.font.lineHeight))
        dayLabel.left = contentFrame.minX
        dayLabel.centerY = contentFrame.minY + contentFrame.height * Metrics.dayCenterRatio

        weekdayLabel.size = CGSize(width: contentFrame.width, height: ceil(weekdayLabel.font.lineHeight))
        weekdayLabel.left = contentFrame.minX
        weekdayLabel.bottom = contentFrame.maxY - contentFrame.height * Metrics.weekdayBottomRatio
    }
}

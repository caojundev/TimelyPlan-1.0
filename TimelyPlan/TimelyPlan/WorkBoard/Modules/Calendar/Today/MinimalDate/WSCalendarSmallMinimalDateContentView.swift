//
//  WSCalendarSmallMinimalDateContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·极简日期：月份与星期靠上左对齐，下半部分放大展示日期。
class WSCalendarSmallMinimalDateContentView: WSCalendarSmallDateContentView {

    private enum Metrics {
        static let insetRatio: CGFloat = 0.09
        static let monthTopRatio: CGFloat = 0.09
        static let titleSpacingRatio: CGFloat = 0.01
        static let dayLeftRatio: CGFloat = 0.11
        static let dayCenterRatio: CGFloat = 0.66
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        monthLabel.textColor = WSCalendarSmallDateAppearance.secondaryTextColor
        weekdayLabel.textColor = WSCalendarSmallDateAppearance.accentColor
        monthLabel.textAlignment = .left
        weekdayLabel.textAlignment = .left
        dayLabel.textAlignment = .left
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局
    override func fontSizes(for contentSize: CGSize) -> (month: CGFloat, weekday: CGFloat, day: CGFloat) {
        let unit = min(contentSize.width, contentSize.height)
        return (unit * 0.09, unit * 0.12, unit * 0.50)
    }

    override func layoutDateLabels(in contentFrame: CGRect) {
        let inset = contentFrame.width * Metrics.insetRatio
        let textWidth = contentFrame.width - inset * 2.0

        monthLabel.size = CGSize(width: textWidth, height: ceil(monthLabel.font.lineHeight))
        monthLabel.left = contentFrame.minX + inset
        monthLabel.top = contentFrame.minY + contentFrame.height * Metrics.monthTopRatio

        weekdayLabel.size = CGSize(width: textWidth, height: ceil(weekdayLabel.font.lineHeight))
        weekdayLabel.left = monthLabel.left
        weekdayLabel.top = monthLabel.bottom + contentFrame.height * Metrics.titleSpacingRatio

        dayLabel.size = CGSize(width: textWidth, height: ceil(dayLabel.font.lineHeight))
        dayLabel.left = contentFrame.minX + contentFrame.width * Metrics.dayLeftRatio
        dayLabel.centerY = contentFrame.minY + contentFrame.height * Metrics.dayCenterRatio
    }
}

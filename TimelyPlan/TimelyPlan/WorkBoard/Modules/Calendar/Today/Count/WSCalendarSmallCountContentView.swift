//
//  WSCalendarSmallCountContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·今日事项数目：上方与极简日期一致但字号缩小一档，左下角展示今日日程数目。
class WSCalendarSmallCountContentView: WSCalendarSmallDateContentView {

    private enum Metrics {
        /// 左右内缩比例
        static let insetRatio: CGFloat = 0.09

        /// 月份距顶比例
        static let monthTopRatio: CGFloat = 0.09

        /// 月份与星期的间距比例
        static let titleSpacingRatio: CGFloat = 0.01

        /// 日期距左比例
        static let dayLeftRatio: CGFloat = 0.11

        /// 日期垂直中心比例
        static let dayCenterRatio: CGFloat = 0.57

        /// 事项数目距底比例
        static let countBottomRatio: CGFloat = 0.06

        /// 事项数目字号比例
        static let countFontRatio: CGFloat = 0.085
    }

    /// 今日事项数目
    private let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        monthLabel.textColor = WSCalendarSmallDateAppearance.secondaryTextColor
        weekdayLabel.textColor = WSCalendarSmallDateAppearance.accentColor
        monthLabel.textAlignment = .left
        weekdayLabel.textAlignment = .left
        dayLabel.textAlignment = .left

        countLabel.textColor = WSCalendarSmallDateAppearance.secondaryTextColor
        countLabel.textAlignment = .left
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.7
        addSubview(countLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局
    /// 比极简日期整体再小一档，为底部的事项数目留出空间
    override func fontSizes(for contentSize: CGSize) -> (month: CGFloat, weekday: CGFloat, day: CGFloat) {
        let unit = min(contentSize.width, contentSize.height)
        return (unit * 0.075, unit * 0.10, unit * 0.40)
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

        /// 事项数目随组件尺寸缩放，贴在左下角
        let countFont = UIFont.systemFont(ofSize: contentFrame.height * Metrics.countFontRatio,
                                          weight: .medium)
        if countLabel.font.pointSize != countFont.pointSize {
            countLabel.font = countFont
        }

        countLabel.size = CGSize(width: textWidth, height: ceil(countLabel.font.lineHeight))
        countLabel.left = contentFrame.minX + inset
        countLabel.bottom = contentFrame.maxY - contentFrame.height * Metrics.countBottomRatio
    }

    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        countLabel.text = (dataItem as? WSCalendarTodayDateDataItem)?.eventCountText
    }
}

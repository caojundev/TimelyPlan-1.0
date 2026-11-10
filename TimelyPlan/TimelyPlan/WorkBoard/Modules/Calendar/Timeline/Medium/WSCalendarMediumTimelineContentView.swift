//
//  WSCalendarMediumTimelineContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历·中·时间线：左侧日期列，右侧展示当前整点起 4 个小时的刻度与事项。
class WSCalendarMediumTimelineContentView: WSCalendarTimelineContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 左侧日期列宽度
        static let dateColumnWidth: CGFloat = 60.0

        /// 日期列内文字与列边缘的间距
        static let dateColumnInset: CGFloat = 4.0

        /// 天与星期的间距
        static let dateLabelSpacing: CGFloat = 2.0

        /// 天的字号
        static let dayFont = UIFont.systemFont(ofSize: 30.0, weight: .semibold)

        /// 星期的字号
        static let weekdayFont = UIFont.systemFont(ofSize: 12.0)
    }

    /// 左侧日期列
    private let dateColumnView = UIView()

    /// 当前日期的天
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.dayFont
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    /// 当前日期是星期几
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.weekdayFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        dateColumnView.isUserInteractionEnabled = false
        dateColumnView.addSubview(dayLabel)
        dateColumnView.addSubview(weekdayLabel)

        addSubview(dateColumnView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据

    override func updateDate(_ date: Date?) {
        dayLabel.text = date.map { "\($0.day)" }
        weekdayLabel.text = date?.shortWeekdaySymbol()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        let dateWidth = min(Metrics.dateColumnWidth, frame.width)
        dateColumnView.frame = CGRect(x: frame.minX,
                                      y: frame.minY,
                                      width: dateWidth,
                                      height: frame.height)
        timelineView.frame = CGRect(x: dateColumnView.right,
                                    y: frame.minY,
                                    width: max(frame.maxX - dateColumnView.right, 0.0),
                                    height: frame.height)

        layoutDateLabels()
    }

    /// 天与星期作为一个整体在日期列内垂直居中
    private func layoutDateLabels() {
        let width = max(dateColumnView.width - Metrics.dateColumnInset * 2.0, 0.0)
        let dayHeight = ceil(Metrics.dayFont.lineHeight)
        let weekdayHeight = ceil(Metrics.weekdayFont.lineHeight)
        let totalHeight = dayHeight + Metrics.dateLabelSpacing + weekdayHeight
        let top = max((dateColumnView.height - totalHeight) / 2.0, 0.0)

        dayLabel.frame = CGRect(x: Metrics.dateColumnInset,
                                y: top,
                                width: width,
                                height: dayHeight)
        weekdayLabel.frame = CGRect(x: Metrics.dateColumnInset,
                                    y: dayLabel.bottom + Metrics.dateLabelSpacing,
                                    width: width,
                                    height: weekdayHeight)
    }
}

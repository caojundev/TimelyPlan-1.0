//
//  WSCalendarLargeTimelineContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

/// 日历·大·时间线：左上角日期信息，下方整块区域展示当前整点起 6 个小时的刻度与事项。
class WSCalendarLargeTimelineContentView: WSCalendarTimelineContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let contentInsets = UIEdgeInsets(value: 10.0)

        /// 星期与天的间距
        static let labelSpacing: CGFloat = 2.0

        /// 日期信息与时间线的间距
        static let timelineSpacing: CGFloat = 4.0

        /// 星期的字号
        static let weekdayFont = UIFont.systemFont(ofSize: 13.0)

        /// 天的字号
        static let dayFont = UIFont.systemFont(ofSize: 32.0, weight: .semibold)
    }

    /// 当前日期是星期几
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.weekdayFont
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    /// 当前日期的天
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.dayFont
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        padding = Metrics.contentInsets

        addSubview(weekdayLabel)
        addSubview(dayLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据

    override func updateDate(_ date: Date?) {
        weekdayLabel.text = date?.shortWeekdaySymbol()
        dayLabel.text = date.map { "\($0.day)" }
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        /// 日期信息放在左上角，星期在上、天在下
        let weekdayHeight = ceil(Metrics.weekdayFont.lineHeight)
        let dayHeight = ceil(Metrics.dayFont.lineHeight)
        
        let labelFrame = frame.inset(by: UIEdgeInsets(left: 16.0))
        weekdayLabel.frame = CGRect(x: labelFrame.minX,
                                    y: labelFrame.minY,
                                    width: labelFrame.width,
                                    height: weekdayHeight)
        dayLabel.frame = CGRect(x: labelFrame.minX,
                                y: weekdayLabel.bottom + Metrics.labelSpacing,
                                width: labelFrame.width,
                                height: dayHeight)

        /// 日期信息下方整块区域为时间线
        let timelineTop = dayLabel.bottom + Metrics.timelineSpacing
        timelineView.frame = CGRect(x: frame.minX,
                                    y: timelineTop,
                                    width: frame.width,
                                    height: max(frame.maxY - timelineTop, 0.0))
    }
}

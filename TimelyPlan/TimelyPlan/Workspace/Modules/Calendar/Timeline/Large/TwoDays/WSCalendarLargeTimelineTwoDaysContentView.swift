//
//  WSCalendarLargeTimelineTwoDaysContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

/// 日历·大·两天时间线：左上角为今天的日期信息，下方左右两列分别为今天与明天的时间线。
class WSCalendarLargeTimelineTwoDaysContentView: WSPluginContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let contentInsets = UIEdgeInsets(value: 10.0)

        /// 星期与天的间距
        static let labelSpacing: CGFloat = 2.0

        /// 日期信息与时间线的间距
        static let timelineSpacing: CGFloat = 4.0

        /// 两列时间线的间距
        static let columnSpacing: CGFloat = 2.0

        /// 星期的字号
        static let weekdayFont = UIFont.systemFont(ofSize: 13.0)

        /// 天的字号
        static let dayFont = UIFont.systemFont(ofSize: 32.0, weight: .semibold)

        /// 右侧时间线标题的字号
        static let tomorrowFont = UIFont.systemFont(ofSize: 11.0)
    }

    /// 今天的时间线（左侧）
    private let todayTimelineView = WSCalendarTimelineView()

    /// 明天的时间线（右侧）
    private let tomorrowTimelineView = WSCalendarTimelineView()

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

    /// 右侧时间线的标题
    private let tomorrowLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.tomorrowFont
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    /// 明天日期，点击右侧空白时打开对应的事项列表
    private var tomorrowDate: Date?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = todayTimelineView.appearance.backgroundColor
        isOpaque = true
        padding = Metrics.contentInsets

        /// 点击事项打开详情
        let selectHandler: (CalendarEvent) -> Void = { [weak self] event in
            self?.interactor?.performAction(with: WSCalendarEventRowItem(event: event))
        }
        todayTimelineView.didSelectEventHandler = selectHandler
        tomorrowTimelineView.didSelectEventHandler = selectHandler

        /// 点击空白位置打开对应日期的事项列表
        todayTimelineView.didTapEmptyHandler = { [weak self] _ in
            guard let self = self else {
                return
            }

            (self.interactor as? WSCalendarEventContentInteractor)?.openEventList(on: Date())
        }
        tomorrowTimelineView.didTapEmptyHandler = { [weak self] _ in
            guard let self = self else {
                return
            }

            (self.interactor as? WSCalendarEventContentInteractor)?.openEventList(on: self.tomorrowDate ?? Date())
        }

        tomorrowLabel.text = resGetString("Tomorrow")

        addSubview(todayTimelineView)
        addSubview(tomorrowTimelineView)
        addSubview(weekdayLabel)
        addSubview(dayLabel)
        addSubview(tomorrowLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSCalendarTimelineTwoDaysDataItem else {
            updateDate(nil)
            tomorrowDate = nil
            todayTimelineView.date = nil
            todayTimelineView.events = []
            tomorrowTimelineView.date = nil
            tomorrowTimelineView.events = []
            return
        }

        updateDate(dataItem.today.date)
        tomorrowDate = dataItem.tomorrow.date
        apply(dataItem.today, to: todayTimelineView)
        apply(dataItem.tomorrow, to: tomorrowTimelineView)
    }

    private func updateDate(_ date: Date?) {
        weekdayLabel.text = date?.shortWeekdaySymbol()
        dayLabel.text = date.map { "\($0.day)" }
    }

    private func apply(_ dataItem: WSCalendarTimelineDataItem, to timelineView: WSCalendarTimelineView) {
        timelineView.startHour = dataItem.startHour
        timelineView.endHour = dataItem.endHour
        timelineView.date = dataItem.date
        timelineView.events = dataItem.events
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
        weekdayLabel.frame = CGRect(x: frame.minX,
                                    y: frame.minY,
                                    width: frame.width,
                                    height: weekdayHeight)
        dayLabel.frame = CGRect(x: frame.minX,
                                y: weekdayLabel.bottom + Metrics.labelSpacing,
                                width: frame.width,
                                height: dayHeight)

        /// 日期信息下方左右两列均为时间线
        let columnWidth = max((frame.width - Metrics.columnSpacing) / 2.0, 0.0)
        let tomorrowLeft = frame.minX + columnWidth + Metrics.columnSpacing

        /// 右侧只有一行小字标题，时间线比左侧更高
        let tomorrowLabelHeight = ceil(Metrics.tomorrowFont.lineHeight)
        tomorrowLabel.frame = CGRect(x: tomorrowLeft,
                                     y: frame.minY,
                                     width: columnWidth,
                                     height: tomorrowLabelHeight)

        let todayTop = dayLabel.bottom + Metrics.timelineSpacing
        todayTimelineView.frame = CGRect(x: frame.minX,
                                         y: todayTop,
                                         width: columnWidth,
                                         height: max(frame.maxY - todayTop, 0.0))

        let tomorrowTop = tomorrowLabel.bottom + Metrics.timelineSpacing
        tomorrowTimelineView.frame = CGRect(x: tomorrowLeft,
                                            y: tomorrowTop,
                                            width: columnWidth,
                                            height: max(frame.maxY - tomorrowTop, 0.0))
    }
}

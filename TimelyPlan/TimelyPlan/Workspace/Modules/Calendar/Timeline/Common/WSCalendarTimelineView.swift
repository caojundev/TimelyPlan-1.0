//
//  WSCalendarTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历时间线视图。
///
/// `rulerView` 作为背景绘制整点刻度，`eventsView` 叠放在刻度线区域内展示事项；
/// 两者共用同一小时范围，事项与刻度线按时间对齐。
class WSCalendarTimelineView: UIView {

    /// 刻度背景
    let rulerView = WSCalendarTimelineRulerView()

    /// 事项层
    let eventsView = WSCalendarTimelineEventsView()

    /// 当前时间指示器
    private let nowIndicatorView = CalendarTimelineDotIndicator()

    /// 指示器高度，与 `CalendarDayTimedEventsView` 一致
    private let nowIndicatorHeight: CGFloat = 10.0

    /// 分钟刷新，用于更新当前时间位置
    private let minuteUpdater = TPMinuteUpdater()

    /// 刻度外观
    var appearance: WSCalendarTimelineRulerAppearance {
        get {
            return rulerView.appearance
        }

        set {
            rulerView.appearance = newValue
        }
    }

    /// 起始小时，取值 0...23
    var startHour: Int {
        get {
            return rulerView.startHour
        }

        set {
            guard rulerView.startHour != newValue else {
                return
            }

            rulerView.startHour = newValue
            updateTimelineRange()
            setNeedsLayout()
        }
    }

    /// 结束小时。小于等于起始小时时按跨天处理
    var endHour: Int {
        get {
            return rulerView.endHour
        }

        set {
            guard rulerView.endHour != newValue else {
                return
            }

            rulerView.endHour = newValue
            updateTimelineRange()
            setNeedsLayout()
        }
    }

    /// 每小时高度。小于等于 0 时按可用高度均分
    var hourHeight: CGFloat {
        get {
            return rulerView.hourHeight
        }

        set {
            guard rulerView.hourHeight != newValue else {
                return
            }

            rulerView.hourHeight = newValue
            setNeedsLayout()
        }
    }

    /// 事项所在的天
    var date: Date? {
        didSet {
            guard date != oldValue else {
                return
            }

            updateTimelineRange()
            updateMinuteUpdater()
        }
    }

    /// 待展示的事项
    var events: [CalendarEvent] = [] {
        didSet {
            eventsView.events = events
        }
    }

    /// 点击事项
    var didSelectEventHandler: ((CalendarEvent) -> Void)? {
        get {
            return eventsView.didSelectEventHandler
        }

        set {
            eventsView.didSelectEventHandler = newValue
        }
    }

    /// 长按事项
    var didLongPressEventHandler: ((CalendarEvent) -> Void)? {
        get {
            return eventsView.didLongPressEventHandler
        }

        set {
            eventsView.didLongPressEventHandler = newValue
        }
    }

    /// 点击空白位置，坐标为视图内坐标
    var didTapEmptyHandler: ((CGPoint) -> Void)? {
        get {
            return eventsView.didTapEmptyHandler
        }

        set {
            eventsView.didTapEmptyHandler = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
        nowIndicatorView.isHidden = true
        addSubview(rulerView)
        addSubview(eventsView)
        addSubview(nowIndicatorView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        /// padding 作为内间距
        let frame = layoutFrame()
        rulerView.frame = frame
        /// 事项层与刻度线区域对齐
        eventsView.frame = rulerView.timelineFrame.offsetBy(dx: frame.minX, dy: frame.minY)
        updateNowIndicator()
    }

    /// 原地修改事项后调用
    func reloadData() {
        eventsView.reloadData()
    }

    /// 按当前小时范围生成时间线日期范围
    private func updateTimelineRange() {
        eventsView.dateRange = makeTimelineRange()
        updateNowIndicator()
    }

    /// 时间线覆盖的日期范围
    private func makeTimelineRange() -> DateInterval? {
        guard let date = date else {
            return nil
        }

        let hours = rulerView.resolvedHours
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let startDate = calendar.date(byAdding: .hour, value: hours.start, to: startOfDay) ?? startOfDay
        let endDate = calendar.date(byAdding: .hour, value: hours.end, to: startOfDay) ?? startOfDay
        return DateInterval(start: startDate, end: endDate)
    }

    // MARK: - 当前时间指示器

    /// 只在展示今天且当前时间落在范围内时显示
    private func updateNowIndicator() {
        let now = Date()
        guard date?.isToday == true,
              let range = makeTimelineRange(),
              range.contains(now),
              eventsView.width > 0.0,
              eventsView.height > 0.0 else {
            nowIndicatorView.isHidden = true
            return
        }

        let progress = CGFloat(now.timeIntervalSince(range.start) / range.duration)
        nowIndicatorView.isHidden = false
        
        let layoutFrame = rulerView.timelineFrame.inset(by: UIEdgeInsets(left: -rulerView.hourLabelSpacing))
        let y = eventsView.top + eventsView.height * progress - nowIndicatorHeight / 2.0
        nowIndicatorView.frame = CGRect(x: layoutFrame.minX,
                                        y: y,
                                        width: layoutFrame.width,
                                        height: nowIndicatorHeight)
    }

    /// 展示今天时才需要跟随当前时间刷新
    private func updateMinuteUpdater() {
        guard date?.isToday == true else {
            minuteUpdater.stop()
            updateNowIndicator()
            return
        }

        minuteUpdater.start { [weak self] in
            self?.updateNowIndicator()
        }
    }
}

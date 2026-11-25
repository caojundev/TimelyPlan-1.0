//
//  WSCalendarTimelineEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 时间线事项层。
///
/// 与刻度视图的刻度区域同尺寸叠放，事项按时间范围等比分布；
/// 重叠事项的轨道划分与 `CalendarDayTimedEventsView` 一致，均使用 `CalendarTimelineLayout`。
class WSCalendarTimelineEventsView: UIView {

    /// 待展示的事项
    var events: [CalendarEvent] = [] {
        didSet {
            reloadData()
        }
    }

    /// 时间线对应的日期范围，为空时不展示事项
    var dateRange: DateInterval? {
        didSet {
            reloadData()
        }
    }

    /// 点击事项
    var didSelectEventHandler: ((CalendarEvent) -> Void)?

    /// 长按事项。未设置时不响应，避免影响组件的长按菜单
    var didLongPressEventHandler: ((CalendarEvent) -> Void)? {
        didSet {
            longPressGesture.isEnabled = didLongPressEventHandler != nil
        }
    }

    /// 点击空白位置，坐标为视图内坐标
    var didTapEmptyHandler: ((CGPoint) -> Void)?

    private var layout: CalendarTimelineLayout?

    private var eventViews: [CalendarEventView] = []

    private lazy var tapGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(handleTap(_:)))

    private lazy var longPressGesture = UILongPressGestureRecognizer(target: self,
                                                                     action: #selector(handleLongPress(_:)))

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
        longPressGesture.isEnabled = false
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(longPressGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let layout = layout, bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }

        layout.containerSize = bounds.size
        for eventView in eventViews {
            eventView.frame = layout.frame(for: eventView.event)
        }
    }

    /// 数据或时间范围变化后重建事项视图
    func reloadData() {
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews.removeAll()

        guard let dateRange = dateRange else {
            layout = nil
            return
        }

        let layout = CalendarTimelineLayout(events: events, dateRange: dateRange)
        self.layout = layout
        eventViews = layout.events.map { event in
            let eventView = CalendarEventView(event: event)
            addSubview(eventView)
            return eventView
        }

        setNeedsLayout()
    }

    // MARK: - 交互

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if let eventView = eventView(at: location) {
            didSelectEventHandler?(eventView.event)
        } else {
            didTapEmptyHandler?(location)
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let eventView = eventView(at: gesture.location(in: self)) else {
            return
        }

        didLongPressEventHandler?(eventView.event)
    }

    /// 取坐标处最上层的事项
    private func eventView(at location: CGPoint) -> CalendarEventView? {
        return eventViews.last { $0.frame.contains(location) }
    }
}

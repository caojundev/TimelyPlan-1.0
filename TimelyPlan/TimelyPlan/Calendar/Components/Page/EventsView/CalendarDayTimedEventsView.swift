//
//  CalendarDayTimedEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

protocol CalendarDayTimedEventsViewDelegate: AnyObject {
    
    // 长按事项
    func calendarDayTimedEventsView(_ view: CalendarDayTimedEventsView, longPressEvent event: CalendarEvent)
    
    // 单击事项
    func calendarDayTimedEventsView(_ view: CalendarDayTimedEventsView, didTapEvent event: CalendarEvent)
    
    // 单击空白位置
    func calendarDayTimedEventsView(_ view: CalendarDayTimedEventsView, didTapLocation location: CGPoint)
}

class CalendarDayTimedEventsView: UIView {
    
    weak var delegate: CalendarDayTimedEventsViewDelegate?
    
    var events: [CalendarEvent]?
    
    var date: Date? {
        didSet {
            setupIndicatorView()
        }
    }
    
    var axisLayout = CalendarAxisLayout() {
        didSet {
            setNeedsLayout()
        }
    }

    private var eventViews: [CalendarEventView] = []
    
    private var layout: CalendarTimelineLayout?
    
    private let contentView = UIView()
    
    /// 时间指示器
    private let indicatorViewHeight = 10.0
    private var indicatorView: CalendarTimelineDotIndicator?
    
    /// 指示器分钟更新器
    private let timerUpdater = TPMinuteUpdater()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.padding = UIEdgeInsets(top: axisLayout.topMargin, bottom: axisLayout.bottomMargin)
        let layoutFrame = layoutFrame()
        contentView.frame = layoutFrame
        
        guard let layout = layout else {
            return
        }

        layout.containerSize = layoutFrame.size
        for eventView in eventViews {
            eventView.frame = layout.frame(for: eventView.event)
        }
    }
    
    // MARK: - 手势
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        let location = gesture.location(in: self)
        if let eventView = eventView(at: location) {
            delegate?.calendarDayTimedEventsView(self, longPressEvent: eventView.event)
        } else {
            delegate?.calendarDayTimedEventsView(self, didTapLocation: location)
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if let eventView = eventView(at: location) {
            delegate?.calendarDayTimedEventsView(self, didTapEvent: eventView.event)
        } else {
            delegate?.calendarDayTimedEventsView(self, didTapLocation: location)
        }
    }
    
    // MARK: - 初始化内容视图
    private func setupContentView() {
        addSubview(contentView)
        setupEventViews()
    }
    
    private func setupEventViews() {
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews.removeAll()
        
        guard let layout = layout else {
            return
        }

        var eventViews = [CalendarEventView]()
        for event in layout.events {
            let eventView = CalendarEventView(event: event)
            contentView.addSubview(eventView)
            eventViews.append(eventView)
        }
        
        self.eventViews = eventViews
    }
    
    func eventView(at point: CGPoint) -> CalendarEventView? {
        let point = convert(point, toViewOrWindow: contentView)
        var results = [CalendarEventView]()
        for eventView in eventViews {
            if eventView.frame.contains(point) {
                results.append(eventView)
            }
        }
        
        return results.last
    }
    
    func reloadData() {
        if let date = date {
            let dateRange = DateInterval.timelineRangeOfDay(date)
            let events = self.events ?? []
            self.layout = CalendarTimelineLayout(events: events, dateRange: dateRange)
        } else {
            self.layout = nil
        }
        
        setupEventViews()
        setupIndicatorView()
        setNeedsLayout()
    }

    /// 重置
    func reset() {
        self.date = nil
        self.events = nil
        self.layout = nil
        self.setupEventViews()
        self.timerUpdater.stop()
    }
    
    // MARK: - 时间指示器
    private func setupIndicatorView() {
        guard let date = date, date.isToday else {
            indicatorView?.removeFromSuperview()
            indicatorView = nil
            timerUpdater.stop()
            return
        }
        
        if indicatorView == nil {
            let view = CalendarTimelineDotIndicator()
            addSubview(view)
            self.indicatorView = view
        }
        
        /// 启动计时器
        timerUpdater.start { [weak self] in
            self?.updateIndicator()
        }
    }
    
    private func updateIndicator() {
        guard let indicatorView = indicatorView else {
            return
        }

        let position = axisLayout.position(of: .now)
        indicatorView.frame = CGRect(x: 0.0,
                                     y: position.y - indicatorViewHeight / 2.0,
                                     width: width,
                                     height: indicatorViewHeight)
    }
}

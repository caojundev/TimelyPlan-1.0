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
    
    var date: Date?
    
    var axisLayout = CalendarAxisLayout() {
        didSet {
            setNeedsLayout()
        }
    }

    private var eventViews: [CalendarEventView] = []
    
    private var layout: CalendarTimelineLayout?
    
    private let contentView = UIView()
    
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let edgeInsets = UIEdgeInsets(top: -axisLayout.topMargin,
                                      bottom: -axisLayout.bottomMargin)
        let hitTestFrame = bounds.inset(by: edgeInsets)
        return hitTestFrame.contains(point)
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
            let dateRange = CalendarTimelineDateRange(date: date)
            let events = self.events ?? []
            self.layout = CalendarTimelineLayout(events: events, dateRange: dateRange)
        } else {
            self.layout = nil
        }
        
        setupEventViews()
        setNeedsLayout()
    }

    /// 重置
    func reset() {
        self.date = nil
        self.events = nil
        self.layout = nil
        self.setupEventViews()
    }
}

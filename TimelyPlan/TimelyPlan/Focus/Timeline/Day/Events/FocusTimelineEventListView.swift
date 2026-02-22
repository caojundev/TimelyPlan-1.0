//
//  FocusTimelineEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation
import UIKit

protocol FocusTimelineEventProvider: AnyObject {
    
    func fetchTimelineEvents(for date: Date, completion: @escaping([FocusTimelineEvent]?) -> Void)
}

/// 时间线事件列表视图点击代理协议
protocol FocusTimelineEventListTapDelegate: AnyObject {
    /// 当用户点击时间线事件时调用
    /// - Parameter event: 被点击的时间线事件
    func didTapTimelineEvent(_ event: FocusTimelineEvent)
}

class FocusTimelineEventListView: UIView {
  
    weak var eventProvider: FocusTimelineEventProvider?
    
    /// 点击事件代理
    weak var tapDelegate: FocusTimelineEventListTapDelegate?
    
    /// 当前时间线所在日期
    var date: Date = .now
    
    var events: [FocusTimelineEvent]?
    
    var eventViews: [FocusTimelineEventView] = []
    
    var hourHeight: CGFloat = 40.0 {
        didSet {
            if hourHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    private var layout: FocusTimelineLayout?
    
    private let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        contentView.frame = CGRect(x: layoutFrame.minX,
                                   y: layoutFrame.minY,
                                   width: layoutFrame.width,
                                   height: layoutFrame.height + hourHeight)
        guard let layout = layout else {
            return
        }

        layout.containerSize = layoutFrame.size
        for eventView in eventViews {
            eventView.frame = layout.frame(for: eventView.event)
        }
    }
    
    private func setupEventViews() {
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews.removeAll()
        guard let events = events else {
            return
        }

        var eventViews = [FocusTimelineEventView]()
        for event in events {
            let eventView = FocusTimelineEventView(event: event)
            eventView.tapDelegate = self
            contentView.addSubview(eventView)
            eventViews.append(eventView)
        }
        
        self.eventViews = eventViews
        self.setNeedsLayout() /// 重新布局
    }
    
    func reset() {
        events = nil
        layout = nil
        setupEventViews()
    }
    
    func reloadData() {
        guard let eventProvider = eventProvider else {
            self.events = nil
            self.layout = nil
            self.setupEventViews()
            return
        }
        
        let date = self.date
        eventProvider.fetchTimelineEvents(for: date, completion: { events in
            guard date == self.date else {
                return
            }
            
            self.events = events
            let dateRange = CalendarTimelineDateRange(date: date)
            self.layout = FocusTimelineLayout(events: events,
                                              dateRange: dateRange)
            self.setupEventViews()
        })
    }
}

// MARK: - FocusTimelineEventTapDelegate
extension FocusTimelineEventListView: FocusTimelineEventTapDelegate {
    func didTapTimelineEvent(_ event: FocusTimelineEvent) {
        tapDelegate?.didTapTimelineEvent(event)
    }
}

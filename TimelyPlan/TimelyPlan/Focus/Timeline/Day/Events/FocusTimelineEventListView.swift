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

class FocusTimelineEventListView: UIView {
  
    weak var eventProvider: FocusTimelineEventProvider?
    
    /// 当前时间线所在日期
    var date: Date = .now
    
    var events: [FocusTimelineEvent]?
    
    var eventViews: [FocusTimelineEventView] = []
    
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
        contentView.frame = layoutFrame
        
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

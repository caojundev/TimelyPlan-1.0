//
//  FocusTimelineEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation
import UIKit

class FocusTimelineEventListView: UIView {
  
    var events: [FocusTimelineEvent]?
    
    var eventViews: [FocusTimelineEventView] = []
    
    private var layout: FocusTimelineLayout?
    
    private let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadEvents()
        setupContentView()
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
    
    private func setupContentView() {
        addSubview(contentView)
        setupEventViews()
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
    }
    
    private func loadEvents() {
        let calendar = Calendar.current
        let now = Date()
    
        let events = [
            FocusTimelineEvent(name: "晨会",
                               color: CalendarEventColor.random,
                               startDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!,
                               endDate: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now)!,
                               focusDuration: 15*60),
            FocusTimelineEvent(name: "产品评审产品评审产品评审产品评审",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 10, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 40, second: 0, of: now)!,
                               focusDuration: 90*60),
            
            FocusTimelineEvent(name: "开发 Coding",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 10, minute: 00, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!,
                               focusDuration: 30*60),
            
            FocusTimelineEvent(name: "阅读",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 13, minute: 00, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 15, minute: 40, second: 0, of: now)!,
                               focusDuration: 160*60),
        ]
        
        self.events = events
        
        let start = Date().startOfDay()
        let end = start.dateByAddingHours(HOURS_PER_DAY)!
        self.layout = FocusTimelineLayout(events: events,
                                          dateRange: (start, end))
    }
    
    func reset() {
        
    }
    
    func eventView(at point: CGPoint) -> FocusTimelineEventView? {
        for eventView in eventViews {
            if eventView.frame.contains(point) {
                return eventView
            }
        }
        
        return nil
    }
    
}

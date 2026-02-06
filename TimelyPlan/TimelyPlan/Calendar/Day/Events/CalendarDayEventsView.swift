//
//  CalendarDayEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/1.
//

import Foundation
import UIKit

class CalendarDayEventsView: UIView {
  
    var events: [CalendarEvent]?
    
    var eventViews: [CalendarEventView] = []
    
    private var layout: CalendarTimelineLayout?
    
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

        var eventViews = [CalendarEventView]()
        for event in events {
            let eventView = CalendarEventView(event: event)
            contentView.addSubview(eventView)
            eventViews.append(eventView)
        }
        
        self.eventViews = eventViews
    }
    
    private func loadEvents() {
        let calendar = Calendar.current
        let now = Date()
    
        let events = [
            CalendarEvent(name: "晨会",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now)!),
            CalendarEvent(name: "产品评审",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 10, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 40, second: 0, of: now)!),
            
            CalendarEvent(name: "开发 Coding",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 10, minute: 00, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!),
            
            CalendarEvent(name: "阅读",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 13, minute: 00, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 15, minute: 40, second: 0, of: now)!),
        ]
        
        self.events = events
        
        let start = Date().startOfDay()
        let end = start.dateByAddingHours(HOURS_PER_DAY)!
        self.layout = CalendarTimelineLayout(events: events, dateRange: (start, end))
    }
    
    func reset() {
        
    }
    
    
    func eventView(at point: CGPoint) -> CalendarEventView? {
        for eventView in eventViews {
            if eventView.frame.contains(point) {
                return eventView
            }
        }
        
        return nil
    }
    
}

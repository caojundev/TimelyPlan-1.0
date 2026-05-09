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
    
    var dateRange: CalendarTimelineDateRange?
    
    private var eventViews: [CalendarEventView] = []
    
    private var layout: CalendarTimelineLayout?
    
    private let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    func eventView(at point: CGPoint) -> CalendarEventView? {
        for eventView in eventViews {
            if eventView.frame.contains(point) {
                return eventView
            }
        }
        
        return nil
    }
    
    func reloadData() {
        if let dateRange = dateRange {
            let events = events ?? []
            self.layout = CalendarTimelineLayout(events: events, dateRange: dateRange)
        } else {
            self.layout = nil
        }
        
        setupEventViews()
        setNeedsLayout()
    }

    /// 重置
    func reset() {
        dateRange = nil
        events = nil
        layout = nil
        setupEventViews()
    }
}

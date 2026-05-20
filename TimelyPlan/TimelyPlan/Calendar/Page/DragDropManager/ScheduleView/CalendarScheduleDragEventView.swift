//
//  CalendarScheduleDragEventView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/17.
//

import Foundation

class CalendarScheduleDragEventView: ScheduleDragView {
    
    let eventView: CalendarEventView
    
    init(event: CalendarEvent) {
        self.eventView = CalendarEventView(event: event)
        self.eventView.isHighlighted = true
        super.init(frame: .zero)
        self.color = event.color.darkerColor
        self.contentView.addSubview(self.eventView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.eventView.frame = bounds
    }
    
}

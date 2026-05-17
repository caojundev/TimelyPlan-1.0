//
//  CalendarScheduleDragEventView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/17.
//

import Foundation

class CalendarScheduleDragEventView: ScheduleDragView {
    
    let event: CalendarEvent
    
    init(event: CalendarEvent) {
        self.event = event
        super.init(frame: .zero)
        
        self.contentView.backgroundColor = .greenPrimary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

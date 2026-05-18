//
//  CalendarDayPageTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation

class CalendarDayPageTimelineCell: CalendarPageTimelineCell {

    override func setupTimelineView() {
        self.timelineView = CalendarPageTimelineView(frame: bounds, mode: .day)
    }
    
}

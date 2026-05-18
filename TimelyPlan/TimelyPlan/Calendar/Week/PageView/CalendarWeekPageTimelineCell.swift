//
//  CalendarWeekPageTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/8.
//

import Foundation
import UIKit

class CalendarWeekPageTimelineCell: CalendarPageTimelineCell {

    var weekPageTimelineView: CalendarWeekPageTimelineView {
        return timelineView as! CalendarWeekPageTimelineView
    }
    
    override func setupTimelineView() {
        timelineView = CalendarWeekPageTimelineView(frame: bounds)
    }
    
}

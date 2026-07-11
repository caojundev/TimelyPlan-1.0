//
//  CalendarUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation

protocol CalendarEventChangeDelegate: AnyObject {
    
    /// 当日历事件发生改变时触发
    func calendarEventsDidChange(in ranges: [DateInterval])
}

class CalendarUpdater: NSObject, CalendarEventChangeDelegate {
    
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        notifyDelegates { (delegate: CalendarEventChangeDelegate) in
            delegate.calendarEventsDidChange(in: ranges)
        }
    }
}

//
//  CalendarUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation

class CalendarUpdater: NSObject, CalendarEventChangeDelegate {
    
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        notifyDelegates { (delegate: CalendarEventChangeDelegate) in
            delegate.calendarEventsDidChange(in: ranges)
        }
    }
}

//
//  GanttUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

protocol GanttEventChangeDelegate: AnyObject {
    
    func ganttEventsDidChange(in ranges: [DateInterval])
}

class GanttUpdater: NSObject, GanttEventChangeDelegate {
    
    func ganttEventsDidChange(in ranges: [DateInterval]) {
        notifyDelegates { (delegate: GanttEventChangeDelegate) in
            delegate.ganttEventsDidChange(in: ranges)
        }
    }
}

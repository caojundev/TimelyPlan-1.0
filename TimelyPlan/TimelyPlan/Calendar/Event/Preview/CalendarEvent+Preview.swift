//
//  CalendarEvent+Preview.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/14.
//

import Foundation
import EventKit

extension CalendarEvent: CalendarEventPreviewDisplayable {
    var eventColor: UIColor? {
        return self.color
    }
    
    var eventTitle: String? {
        self.title
    }
    
    var dateInfo: (title: String?, subtitle: String?) {
        var title: String?
        var subtitle: String?
        
        let allDayString = resGetString("All day")
        if spansMultipleDays {
            let startString = startDate.yearMonthDayWeekdaySymbolString(style: .full,
                                                                        omitYear: true,
                                                                        showRelativeDate: false)
            let endString = endDate.yearMonthDayWeekdaySymbolString(style: .full,
                                                                    omitYear: true,
                                                                    showRelativeDate: false)
            if isAllDay, startDate.isStartOfDay, endDate.isEndOfDay {
                title = "\(startString) - \(endString)"
                subtitle = allDayString
            } else {
                title = startDate.timeString + " - " + startString
                subtitle = endDate.timeString + " - " + endString
            }
        } else {
            title = startDate.yearMonthDayWeekdaySymbolString(style: .full,
                                                              omitYear: true,
                                                              showRelativeDate: false)
            if isAllDay {
                subtitle = allDayString
            } else {
                subtitle = "\(startDate.timeString) - \(endDate.timeString)"
            }
        }
        
        return (title, subtitle)
    }
    
    var sourceDescription: String? {
        switch source {
        case .local:
            return resGetString("Todo")
        case .system:
            return systemCalendarDescription
        }
    }
    
    private var systemCalendarDescription: String? {
        guard let event = sourceItem as? EKEvent else {
            return nil
        }
        
        if let calendar = event.calendar {
            return "\(calendar.title)(\(resGetString(calendar.source.title)))"
        }
        
        return nil
    }
}

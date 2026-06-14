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
    
    var repeatInfo: (ruleDescription: String?, endDescription: String?)? {
        switch source {
        case .local:
            return nil
        case .system:
            return systemEventRepeatInfo
        }
    }
    
    var alarmDescription: String? {
        switch source {
        case .local:
            return nil
        case .system:
            return systemEventAlarmDescription
        }
    }
    
    var sourceDescription: String? {
        switch source {
        case .local:
            return resGetString("Todo")
        case .system:
            return systemEventSourceDescription
        }
    }
    
    // MARK: - Helpers
    private var systemEventRepeatInfo: (ruleDescription: String?, endDescription: String?)? {
        guard let event = sourceItem as? EKEvent, event.hasRecurrenceRules else {
            return nil
        }
        
        let ruleDescription = event.recurrenceDescription
        let endDescription = event.repeatEndDescription
        return (ruleDescription, endDescription)
    }
    
    private var systemEventAlarmDescription: String? {
        guard let event = sourceItem as? EKEvent, event.hasAlarms else {
            return nil
        }
        
        return event.alarmDescription
    }
    
    private var systemEventSourceDescription: String? {
        guard let event = sourceItem as? EKEvent else {
            return nil
        }
        
        if let calendar = event.calendar {
            return "\(calendar.title)(\(resGetString(calendar.source.title)))"
        }
        
        return nil
    }
}

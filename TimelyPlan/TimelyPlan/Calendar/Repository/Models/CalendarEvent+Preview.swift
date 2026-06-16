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
            return localRepeatInfo
        case .system:
            return systemRepeatInfo
        }
    }
    
    var alarmDescription: String? {
        switch source {
        case .local:
            return localAlarmDescription
        case .system:
            return systemAlarmDescription
        }
    }
    
    var sourceDescription: String? {
        switch source {
        case .local:
            return localSourceDescription
        case .system:
            return systemSourceDescription
        }
    }
    
    var isEditable: Bool {
        switch source {
        case .local:
            if let task = sourceItem as? TodoTask {
                /// 重复任务不可编辑
                return !task.isDetached
            } else {
                return false
            }
        case .system:
            if let event = sourceItem as? EKEvent {
                return event.isEditable
            } else {
                return false
            }
        }
    }
    
    var isDeletable: Bool {
        switch source {
        case .local:
            return isEditable
        case .system:
            if let event = sourceItem as? EKEvent {
                return event.isDeletable
            } else {
                return false
            }
        }
    }
    
    // MARK: - Helpers
    private var localRepeatInfo: (ruleDescription: String?, endDescription: String?)? {
        guard let task = sourceItem as? TodoTask,
              let eventDate = task.startDate,
              let repeatRule = task.schedule?.repeatRule,
                repeatRule.type != RepeatType.none else {
            return nil
        }
        
        let title = repeatRule.title(for: eventDate)
        let subtitle = repeatRule.subtitle(for: eventDate, showRepeatCount: false)
        return (title, subtitle)
    }
    
    private var systemRepeatInfo: (ruleDescription: String?, endDescription: String?)? {
        guard let event = sourceItem as? EKEvent, event.hasRecurrenceRules else {
            return nil
        }
        
        let ruleDescription = event.recurrenceDescription
        let endDescription = event.repeatEndDescription
        return (ruleDescription, endDescription)
    }
    
    private var localAlarmDescription: String? {
        guard let task = sourceItem as? TodoTask,
              let dateInfo = task.schedule?.dateInfo,
              let reminder = task.reminder, reminder.hasAlarm else {
            return nil
        }
        
        return reminder.info(with: dateInfo)
    }
    
    private var systemAlarmDescription: String? {
        guard let event = sourceItem as? EKEvent, event.hasAlarms else {
            return nil
        }
        
        return event.alarmDescription
    }
    
    private var localSourceDescription: String? {
        guard let task = sourceItem as? TodoTask else {
            return nil
        }
        
        let string = resGetString("Todo")
        if task.isDetached {
            return string + "(\(resGetString("Repeat Task")))"
        }
        
        return string
    }
    
    private var systemSourceDescription: String? {
        guard let event = sourceItem as? EKEvent else {
            return nil
        }
        
        if let calendar = event.calendar {
            return "\(calendar.title)(\(resGetString(calendar.source.title)))"
        }
        
        return nil
    }
}

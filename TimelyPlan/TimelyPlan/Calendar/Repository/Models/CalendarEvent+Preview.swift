//
//  CalendarEvent+Preview.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/14.
//

import Foundation
import EventKit

extension CalendarEvent: CalendarEventPreviewDisplayable {

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
        case .system:
            return systemRepeatInfo
        case .todo:
            return todoRepeatInfo
        case .habit:
            return habitRepeatInfo
        }
    }
    
    var alarmDescription: String? {
        switch source {
        case .system:
            return systemAlarmDescription
        case .todo:
            return todoAlarmDescription
        case .habit:
            return habitAlarmDescription
        }
    }
    
    var sourceDescription: String? {
        switch source {
        case .system:
            return systemSourceDescription
        case .todo:
            return todoSourceDescription
        case .habit:
            return habitSourceDescription
        }
    }
    
    var isEditable: Bool {
        switch source {
        case .system:
            if let event = sourceItem as? EKEvent {
                return event.isEditable
            } else {
                return false
            }
        case .todo:
            if let task = sourceItem as? TodoTask {
                /// 重复任务不可编辑
                return !task.isDetached
            } else {
                return false
            }
        case .habit:
            return false
        }
    }
    
    var isDeletable: Bool {
        switch source {
        case .system:
            if let event = sourceItem as? EKEvent {
                return event.isDeletable
            } else {
                return false
            }
        case .todo:
            return isEditable
        case .habit:
            return false
        }
    }
    
    // MARK: - Helpers
    private var todoRepeatInfo: (ruleDescription: String?, endDescription: String?)? {
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
    
    private var habitRepeatInfo: (ruleDescription: String?, endDescription: String?)? {
        guard let task = sourceItem as? HabitTask else {
            return nil
        }
        
        let timePlan = task.timePlan
        var repeatParts = [String]()
        if let repeatTitle = timePlan.title {
            repeatParts.append(repeatTitle)
        }
        
        if let repeatSubtitle = timePlan.subtitle {
            repeatParts.append(repeatSubtitle)
        }
    
        let title = repeatParts.joined(separator: ", ")
        var subtitle: String?
        if let endDate = task.dateRange.endDate {
            let format = resGetString("Until %@")
            subtitle = String(format: format, endDate.yearMonthDayString(omitYear: true))
        }
        
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
    
    private var todoAlarmDescription: String? {
        guard let task = sourceItem as? TodoTask,
              let dateInfo = task.schedule?.dateInfo,
              let reminder = task.reminder, reminder.hasAlarm else {
            return nil
        }
        
        return reminder.info(with: dateInfo)
    }
    
    private var habitAlarmDescription: String? {
        guard let task = sourceItem as? HabitTask, task.hasAlarm,
              let date = task.dateRange.startDate,
              let alarmDates = task.reminder?.alarmDates(for: date) else {
            return nil
        }
        
        let timeStrings = alarmDates.map { $0.timeString}
        if timeStrings.count > 0 {
            return timeStrings.joined(separator: ", ")
        }
        
        return nil
    }
    
    private var systemAlarmDescription: String? {
        guard let event = sourceItem as? EKEvent, event.hasAlarms else {
            return nil
        }
        
        return event.alarmDescription
    }
    
    private var todoSourceDescription: String? {
        guard let task = sourceItem as? TodoTask else {
            return nil
        }
        
        let string = resGetString("Todo")
        if task.isDetached {
            return string + "(\(resGetString("Repeat Task")))"
        }
        
        return string
    }
    
    private var habitSourceDescription: String? {
        return resGetString("Habit")
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

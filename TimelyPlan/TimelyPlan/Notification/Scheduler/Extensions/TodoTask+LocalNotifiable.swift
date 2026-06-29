//
//  TodoTask+LocalNotifiable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/25.
//

import Foundation

extension TodoTask: LocalNotifiable {
    
    var displayName: String {
        return name ?? resGetString("Untitled Todo Task")
    }
    
    var taskIdentifier: String {
        return identifier
    }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        guard !isCompleted,
              let schedule = schedule,
              let dateInfo = schedule.dateInfo else {
            return []
        }
        
        let title = displayName
        var configs = [TaskNotificationConfig]()
        if let startAlarmDates = schedule.startAlarmDates {
            let startSound = TodoSetting.shared.startSound?.toUNNotificationSound
            for alarmDate in startAlarmDates {
                let body = formatStartsBodyString(dateInfo: dateInfo,
                                                  alarmDate: alarmDate)
                let config = TaskNotificationConfig(
                    taskIdentifier: taskIdentifier,
                    title: title,
                    body: body,
                    triggerDate: alarmDate,
                    sound: startSound
                )
                
                configs.append(config)
            }
        }
        
        if let endAlarmDates = schedule.endAlarmDates {
            let dueSound = TodoSetting.shared.dueSound?.toUNNotificationSound
            for alarmDate in endAlarmDates {
                let body = formatDueBodyString(dateInfo: dateInfo,
                                               alarmDate: alarmDate)
                let config = TaskNotificationConfig(
                    taskIdentifier: taskIdentifier,
                    title: title,
                    body: body,
                    triggerDate: alarmDate,
                    sound: dueSound
                )
                
                configs.append(config)
            }
        }
        
        return configs
    }
    
    // MARK: - 通知 Body
    
    // 开始提醒
    func formatStartsBodyString(dateInfo: TaskDateInfo, alarmDate: Date) -> String {
        var strings = [String]()
        var startString: String?
        if dateInfo.isAllDay {
            startString = formatAllDayStartsInText(alarmDate: alarmDate,
                                                   eventDate: dateInfo.startDate)
        } else {
            startString = formatTimedStartsInText(alarmDate: alarmDate,
                                                  eventDate: dateInfo.startDate)
        }
        
        if let startString = startString {
            strings.append(startString)
        }
        
        let eventDateString = eventDateString(with: dateInfo.startDate,
                                              isAllDay: dateInfo.isAllDay,
                                              alarmDate: alarmDate)
        strings.append(eventDateString)
        return strings.joined(separator: " • ")
    }

    func formatAllDayStartsInText(alarmDate: Date, eventDate: Date) -> String? {
        guard eventDate >= alarmDate else {
            return nil
        }
        
        let days = Date.days(fromDate: alarmDate, toDate: eventDate)
        guard days >= 0 else {
            return resGetString("Start")
        }
        
        if days == 0 {
            return resGetString("Starts today")
        }
        
        if days == 1 {
            return resGetString("Starts tomorrow")
        }
        
        let format = resGetString("Starts in %@")
        return String(format: format, days.dayCountString)
    }

    func formatTimedStartsInText(alarmDate: Date, eventDate: Date) -> String? {
        guard eventDate >= alarmDate else {
            return nil
        }
        
        let days = Date.days(fromDate: alarmDate, toDate: eventDate)
        guard days >= 0 else {
            return resGetString("Starting now")
        }
        
        if days == 1 {
            return resGetString("Starts tomorrow")
        }
        
        var timeString: String?
        if days > 1 {
            /// 大于一天仅提供天信息
            timeString = days.dayCountString
        } else {
            /// 同一天提供时和分信息
            let difference = eventDate.timeIntervalSince(alarmDate)
            timeString = formattedTime(from: Int(difference))
        }
        
        if let timeString = timeString {
            let format = resGetString("Starts in %@")
            return String(format: format, timeString)
        }
        
        return resGetString("Starting now")
    }
    
    /// 截止提醒
    func formatDueBodyString(dateInfo: TaskDateInfo, alarmDate: Date) -> String {
        var strings = [String]()
        var dueString: String?
        if dateInfo.isAllDay {
            dueString = formatAllDayDueInText(alarmDate: alarmDate, eventDate: dateInfo.endDate)
        } else {
            dueString = formatTimedDueInText(alarmDate: alarmDate, eventDate: dateInfo.endDate)
        }
        
        if let dueString = dueString {
            strings.append(dueString)
        }
        
        let eventDateString = eventDateString(with: dateInfo.endDate,
                                              isAllDay: dateInfo.isAllDay,
                                              alarmDate: alarmDate)
        strings.append(eventDateString)
        return strings.joined(separator: " • ")
    }
    
    func formatAllDayDueInText(alarmDate: Date, eventDate: Date) -> String? {
        guard eventDate >= alarmDate else {
            return nil
        }
        
        let days = Date.days(fromDate: alarmDate, toDate: eventDate)
        guard days >= 0 else {
            return resGetString("Due")
        }
        
        if days == 0 {
            return resGetString("Due today")
        }
        
        if days == 1 {
            return resGetString("Due tomorrow")
        }
        
        let format = resGetString("Due in %@")
        return String(format: format, days.dayCountString)
    }
    
    func formatTimedDueInText(alarmDate: Date, eventDate: Date) -> String? {
        guard eventDate >= alarmDate else {
            return nil
        }
        
        let days = Date.days(fromDate: alarmDate, toDate: eventDate)
        guard days >= 0 else {
            return resGetString("Due now")
        }
        
        if days == 1 {
            return resGetString("Due tomorrow")
        }
        
        var timeString: String?
        if days > 1 {
            /// 大于一天仅提供天信息
            timeString = days.dayCountString
        } else {
            /// 同一天提供时和分信息
            let difference = eventDate.timeIntervalSince(alarmDate)
            timeString = formattedTime(from: Int(difference))
        }
        
        if let timeString = timeString {
            let format = resGetString("Due in %@")
            return String(format: format, timeString)
        }
         
        return resGetString("Due now")
    }
    
    private func formattedTime(from totalSeconds: Int) -> String? {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        var parts: [String] = []
        if hours > 0   { parts.append(hours.hourCountStirng) }
        if minutes > 0 { parts.append(minutes.minuteCountStirng) }
        if parts.count == 2 {
            let format = resGetString("%@ %@")
            return String(format: format, parts[0], parts[1])
        } else if parts.count == 1 {
            return parts[0]
        }
        
        return nil
    }
    
    private func eventDateString(with date: Date,
                                 isAllDay: Bool,
                                 alarmDate: Date) -> String {
        if isAllDay {
            let dateString = date.yearMonthDayString(omitYear: true,
                                                     relativeDate: alarmDate)
            return dateString + "(\(resGetString("All-Day")))"
        } else {
            let dateString = date.yearMonthDayTimeString(omitYear: true,
                                                         relativeDate: alarmDate,
                                                         slashFormatted: false)
            return dateString
        }
    }
}

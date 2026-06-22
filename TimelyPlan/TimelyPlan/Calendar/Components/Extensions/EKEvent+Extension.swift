//
//  EKEvent+Extension.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation
import EventKit

// MARK: - EKEvent 扩展
struct EventPermissions {
    let canView: Bool
    let canEdit: Bool
    let canDelete: Bool
}

extension EKEvent {
    
    /// 综合判断：返回事件的操作权限
    var permissions: EventPermissions {
        guard self.calendar != nil else {
            return EventPermissions(canView: false, canEdit: false, canDelete: false)
        }
        
        return EventPermissions(canView: true,
                                canEdit: isEditable,
                                canDelete: isDeletable)
    }
    
    /// 判断事件是否可编辑
    var isEditable: Bool {
        guard let calendar = self.calendar else {
            // 事件没有关联日历
            return false
        }
        
        // 检查是否允许修改
        guard calendar.allowsContentModifications else {
            // 此日历不允许修改内容（如订阅日历、生日日历）
            return false
        }
        
        // 检查日历来源类型
        switch calendar.source.sourceType {
        case .birthdays, .subscribed:
            return false
        case .calDAV, .exchange:
            // 这些类型通常可编辑，但需检查权限
            break
        default:
            break
        }
        
        return true
    }
    
    /// 判断事件是否可删除
    var isDeletable: Bool {
        guard isEditable else {
            return false
        }
        
        if let organizer = self.organizer, !organizer.isCurrentUser {
            // 某些 Exchange/CalDAV 日历中，非组织者不能删除
            let sourceType = calendar.source.sourceType
            if sourceType == .exchange || sourceType == .calDAV {
                /// 只有事件创建者才能删除
                return false
            }
        }
        
        return true
    }
}

// MARK: - 重复和提醒描述
extension EKEvent {
    
    // MARK: - 重复规则描述
    
    /// 获取重复规则的文本描述
    var recurrenceDescription: String? {
        guard let recurrenceRules = self.recurrenceRules,
              let rule = recurrenceRules.first else {
            return nil
        }
        return describeRecurrenceRule(rule)
    }
    
    var repeatEndDescription: String? {
        guard let recurrenceRules = self.recurrenceRules,
              let rule = recurrenceRules.first else {
            return nil
        }
        
        return endDescription(rule.recurrenceEnd)
    }
    
    private func describeRecurrenceRule(_ rule: EKRecurrenceRule) -> String {
        let frequencyText = frequencyDescription(rule.frequency)
        let intervalText = intervalDescription(rule.interval, frequency: rule.frequency)
        var parts = [String]()
        
        // 基本频率
        if rule.frequency == .daily {
            if let intervalText = intervalText {
                parts.append(intervalText)
            } else {
                parts.append(frequencyText)
            }
        } else {
            parts.append(frequencyText)
            if let intervalText = intervalText {
                parts.append(intervalText)
            }
        }
        
        // 按星期几重复
        if let daysDescription = daysOfWeekDescription(rule.daysOfTheWeek) {
            parts.append(daysDescription)
        }
        
        // 按月份中的日期重复
        if let daysOfMonthDescription = daysOfMonthDescription(rule.daysOfTheMonth) {
            parts.append(daysOfMonthDescription)
        }
        
        // 按年份中的月份重复
        if let monthsDescription = monthsOfYearDescription(rule.monthsOfTheYear) {
            parts.append(monthsDescription)
        }
        
        return parts.joined(separator: resGetString(", "))
    }

    // MARK: - 频率描述
    
    private func frequencyDescription(_ frequency: EKRecurrenceFrequency) -> String {
        switch frequency {
        case .daily:    return resGetString("Every Day")
        case .weekly:   return resGetString("Every Week")
        case .monthly:  return resGetString("Every Month")
        case .yearly:   return resGetString("Every Year")
        @unknown default: return resGetString("Custom")
        }
    }
    
    // MARK: - 间隔描述
    
    private func intervalDescription(_ interval: Int, frequency: EKRecurrenceFrequency) -> String? {
        guard interval > 1 else { return nil }
        
        switch frequency {
        case .daily:    return String(format: resGetString("Every %ld Days"), interval)
        case .weekly:   return String(format: resGetString("Every %ld Weeks"), interval)
        case .monthly:  return String(format: resGetString("Every %ld Months"), interval)
        case .yearly:   return String(format: resGetString("Every %ld Years"), interval)
        @unknown default: return nil
        }
    }
    
    // MARK: - 星期描述
    
    private func daysOfWeekDescription(_ days: [EKRecurrenceDayOfWeek]?) -> String? {
        guard let days = days, !days.isEmpty else { return nil }
        let weekdaySymbols = Calendar.current.shortWeekdaySymbols
        let dayNames = days.compactMap { day -> String? in
            let dayOfTheWeek = day.dayOfTheWeek.rawValue
            guard dayOfTheWeek >= 1 && dayOfTheWeek <= 7 else { return nil }
            let index = dayOfTheWeek - 1
            return weekdaySymbols[safe: index]
        }
        
        guard !dayNames.isEmpty else { return nil }
        
        let daysText = dayNames.joined(separator: resGetString(", "))
        return String(format: resGetString("on %@"), daysText)
    }
    
    // MARK: - 月份日期描述
    
    private func daysOfMonthDescription(_ days: [NSNumber]?) -> String? {
        guard let days = days, !days.isEmpty else { return nil }
        
        let dayNumbers = days.map { $0.intValue }.sorted()
        let dayStrings = dayNumbers.map { String(format: resGetString("%ldth"), $0) }
        
        let daysText = dayStrings.joined(separator: resGetString(", "))
        return String(format: resGetString("on %@"), daysText)
    }
    
    // MARK: - 月份描述
    
    private func monthsOfYearDescription(_ months: [NSNumber]?) -> String? {
        guard let months = months, !months.isEmpty else { return nil }
        
        let monthSymbols = Calendar.current.shortMonthSymbols
        let monthNumbers = months.map { $0.intValue }.sorted()
        let monthNames = monthNumbers.compactMap { monthSymbols[safe: $0 - 1] }
        
        guard !monthNames.isEmpty else { return nil }
        
        let monthsText = monthNames.joined(separator: resGetString(", "))
        return String(format: resGetString("in %@"), monthsText)
    }
    
    // MARK: - 结束规则描述
    
    private func endDescription(_ end: EKRecurrenceEnd?) -> String? {
        guard let end = end else { return nil }
        
        if let endDate = end.endDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = Locale.current
            return String(format: resGetString("Ends on %@"), formatter.string(from: endDate))
        } else if end.occurrenceCount > 0 {
            return String(format: resGetString("Repeat %ld Times"), end.occurrenceCount)
        }
        
        return nil
    }
    
    
    // MARK: - 提醒时间描述

    /// 获取提醒时间的文本描述
    var alarmDescription: String? {
        guard let alarms = self.alarms, !alarms.isEmpty else {
            return nil
        }
        
        var alarmDescriptions: [String] = []
        for alarm in alarms {
            if let alarmDescription = describeAlarm(alarm) {
                alarmDescriptions.append(alarmDescription)
            }
        }
        
        return alarmDescriptions.joined(separator: resGetString(", "))
    }

    // MARK: - Private
    private func describeAlarm(_ alarm: EKAlarm) -> String? {
        // 绝对时间提醒
        if let absoluteDate = alarm.absoluteDate {
            return absoluteDate.yearMonthDayTimeString(omitYear: true,
                                                       showRelativeDate: false,
                                                       slashFormatted: false)
        }
        
        // 位置提醒
        if let _ = alarm.structuredLocation, alarm.proximity != .none {
            return alarm.proximity == .enter ? resGetString("When Arriving") : resGetString("When Leaving")
        }
        
        let offset = alarm.relativeOffset
        guard let alarmDate = startDate.dateByAddingSeconds(Int(offset)) else {
            return nil
        }

        let timeString = alarmDate.timeString
        let days = Date.days(fromDate: startDate, toDate: alarmDate)
        if days == 0 {
            return String(format: resGetString("On day of event (%@)"), timeString)
        }
        
        if days < 0 {
            let interval = -days
            let intervalString = interval == 1 ? resGetString("1 day") : String(format: resGetString("%ld days"), interval)
            return String(format: resGetString("%@ before (%@)"), intervalString, timeString)
        }
        
        return nil
    }
}

// MARK: - CalendarEvent 转换
extension EKEvent {
    
    /// 是否横跨多天
    var spanMultipleDays: Bool {
        return Date.days(fromDate: startDate, toDate: endDate) != 0
    }
    
    func toCalendarEvent() ->  CalendarEvent? {
        guard let identifier = self.eventIdentifier else {
            return nil
        }
        
        let color: UIColor
        if let cgColor = self.calendar.cgColor {
            color = UIColor(cgColor: cgColor)
        } else {
            color = .systemBlue
        }
        
        var isAllDay = self.isAllDay
        if !isAllDay {
            /// 跨天任务，显示为全天事项
            isAllDay = spanMultipleDays
        }
        
        return CalendarEvent(
            identifier: identifier,
            source: .system,
            name: self.title,
            color: color,
            startDate: self.startDate,
            endDate: self.endDate,
            isAllDay: isAllDay,
            isCompleted: false,
            sourceItem: self
        )
    }
}

// MARK: - Array 扩展
extension Array where Element == EKEvent {
    
    func toCalendarEvents() -> [CalendarEvent] {
        var results = [CalendarEvent]()
        for ekEvent in self {
            if let event = ekEvent.toCalendarEvent() {
                results.append(event)
            }
        }
        
        return results
    }
}

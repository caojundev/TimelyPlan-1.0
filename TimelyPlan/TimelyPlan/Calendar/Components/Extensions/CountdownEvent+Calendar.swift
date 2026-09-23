//
//  CountdownEvent+Calendar.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/23.
//

import Foundation

extension CountdownEvent {

    /// 日历显示窗口及其对应的发生日
    private struct DisplayWindow {
        
        /// 窗口日期区间
        let interval: DateInterval
        
        /// 标题参考日期（倒数取发生日、正数取起始日）
        let occurrence: Date
    }

    /// 日历事件（按 `calendarDisplayMode` 决定在区间内需要显示的天数）
    func calendarEvents(in range: DateInterval) -> [CalendarEvent]? {
        guard calendarDisplayMode != .none else {
            return nil
        }
        
        /// 过滤基准日期
        /// - 正数事项：目标日期在过去，今天显示
        /// - 倒数事项：目标日期在未来，丢弃今天之前的日期
        let referenceRange: DateInterval
        switch effectiveCountingType {
        case .countUp:
            let start = Date().startOfDay()
            let end = start.endOfDay()
            referenceRange = DateInterval(start: start, end: end)
        case .countdown:
            referenceRange = DateInterval(start: Date().startOfDay(),
                                          end: .distantFuture)
        }
        
        /// 先按基准日期收缩查询区间，避免对基准日之前的日期做无效的窗口计算
        guard let displayRange = referenceRange.intersection(with: range) else {
            return nil
        }

        /// 汇总每一天及其对应的发生日（均不早于基准日期），后续直接用两者计算标题
        var dayOccurrences = [Date: Date]()
        for window in displayWindows(in: displayRange) {
            guard let clipped = window.interval.intersection(with: displayRange) else {
                continue
            }
            
            clipped.enumerateDays { date in
                let day = date.startOfDay()
                /// 同一天可能落在多个窗口内，取最近（最早）的发生日
                if let occurrence = dayOccurrences[day] {
                    dayOccurrences[day] = min(occurrence, window.occurrence)
                } else {
                    dayOccurrences[day] = window.occurrence
                }
                
                return true
            }
        }
        
        guard dayOccurrences.count > 0 else {
            return nil
        }
        
        return dayOccurrences.sorted { $0.key < $1.key }.map {
            calendarEvent(on: $0.key, occurrence: $0.value)
        }
    }
    
    // MARK: - Helpers
    /// 日历显示窗口
    private func displayWindows(in range: DateInterval) -> [DisplayWindow] {
        switch calendarDisplayMode {
        case .none:
            return []
        case .always:
            /// 一直显示：覆盖整个查询区间
            return alwaysVisibleWindows(in: range)
        case .onTheDay:
            return occurrenceDates(from: range.start, to: range.end).map { occurrence in
                DisplayWindow(interval: .rangeOfDay(occurrence),
                              occurrence: windowTitleDate(for: occurrence))
            }
        case .daysBefore(let days):
            let advanceDays = CountdownDisplayMode.validDays(days)
            /// 发生日最晚可超出区间 advanceDays 天，其显示窗口仍可能与区间相交
            let searchEnd = range.end.dateByAddingDays(advanceDays) ?? range.end
            return occurrenceDates(from: range.start, to: searchEnd).compactMap { occurrence in
                guard let startDate = occurrence.dateByAddingDays(-advanceDays) else {
                    return nil
                }
                
                return DisplayWindow(interval: DateInterval(start: startDate.startOfDay(),
                                                           end: occurrence.endOfDay()),
                                     occurrence: windowTitleDate(for: occurrence))
            }
        }
    }
    
    /// 一直显示的窗口：按天推进对应的发生日，避免逐日重复推算
    private func alwaysVisibleWindows(in range: DateInterval) -> [DisplayWindow] {
        var windows = [DisplayWindow]()
        var day = range.start.startOfDay()
        var occurrence = nextTitleDate(on: day)
        while day <= range.end {
            windows.append(DisplayWindow(interval: .rangeOfDay(day), occurrence: occurrence))
            
            guard let nextDay = day.dateByAddingDays(1) else {
                break
            }
            
            /// 越过当前发生日时推进到下一个发生日
            if nextDay > occurrence {
                occurrence = nextTitleDate(on: nextDay)
            }
            
            day = nextDay
        }
        
        return windows
    }
    
    /// 特定显示日对应的标题参考日期（倒数取不早于该日的下一个发生日，正数取起始日）
    private func nextTitleDate(on day: Date) -> Date {
        switch effectiveCountingType {
        case .countdown:
            return timePlan.nextPlanDate(from: day, startDate: date)?.targetDate ?? date.targetDate
        case .countUp:
            return date.targetDate
        }
    }
    
    /// 窗口发生日对应的标题参考日期（倒数取该发生日，正数取起始日）
    private func windowTitleDate(for occurrence: Date) -> Date {
        switch effectiveCountingType {
        case .countdown:
            return occurrence
        case .countUp:
            return date.targetDate
        }
    }
    
    /// 特定区间内的发生日（区间外不含）
    func occurrenceDates(from startDate: Date, to endDate: Date) -> [Date] {
        let searchRange = DateInterval(start: startDate, end: endDate)
        
        /// 无重复规则：仅目标日期本身
        if timePlan.type == nil || timePlan.type == CountdownTimePlanType.none {
            let targetDate = date.targetDate
            guard targetDate >= searchRange.start.startOfDay(),
                  targetDate <= searchRange.end else {
                return []
            }
            
            return [targetDate]
        }
        
        /// 重复规则：逐个推算区间内的发生日
        var results = [Date]()
        var referenceDate = searchRange.start
        while let planDate = timePlan.nextPlanDate(from: referenceDate, startDate: date),
              planDate.targetDate <= searchRange.end {
            /// 防御：异常规则返回未推进的日期时终止循环
            if let lastDate = results.last, planDate.targetDate <= lastDate {
                break
            }
            
            results.append(planDate.targetDate)
            
            guard let nextReferenceDate = planDate.targetDate.dateByAddingDays(1) else {
                break
            }
            
            referenceDate = nextReferenceDate
        }
    
        return results
    }
    
    /// 单个日历事件（倒数日为全天事项）
    private func calendarEvent(on day: Date, occurrence: Date) -> CalendarEvent {
        let interval = DateInterval.rangeOfDay(day)
        let event = CalendarEvent(identifier: identifier,
                                  source: .countdown,
                                  name: calendarDisplayTitle(on: day, occurrence: occurrence),
                                  color: color ?? type.color,
                                  startDate: interval.start,
                                  endDate: interval.end,
                                  isAllDay: true,
                                  isCompleted: false,
                                  sourceItem: self)
        return event
    }
    
    /// 日历中显示的名称（表情 + 名称 + 相对发生日期的说明）
    private func calendarDisplayTitle(on day: Date, occurrence: Date) -> String {
        let title = (emoji ?? type.emoji) + displayName
        guard let description = relativeDateDescription(on: day, occurrence: occurrence) else {
            return title
        }
        
        return title + " • " + description
    }
    
    /// 相对显示日期的说明
    ///
    /// - 倒数事项：`x天后` / `明天` / `今天`
    /// - 正数事项：`已过x天`
    /// - Returns: 无有效差值时返回 `nil`
    private func relativeDateDescription(on day: Date, occurrence: Date) -> String? {
        let countingType = effectiveCountingType
        let days = CountdownCalculator.days(referenceDate: day,
                                            targetDate: occurrence,
                                            countingType: countingType,
                                            includeStartDate: includesStartDate)

        switch countingType {
        case .countdown:
            /// 距离发生日的剩余天数
            guard days >= 0 else {
                return nil
            }
            
            if days == 0 {
                return resGetString("Today")
            }
            
            if days == 1 {
                return resGetString("Tomorrow")
            }
            
            return String(format: resGetString("%@ later"), days.dayCountString)
        case .countUp:
            if day.isInSameDayAs(occurrence) {
                return resGetString("Today")
            }
            
            return String(format: resGetString("%@ passed"), days.dayCountString)
        }
    }
}

// MARK: - Array 扩展
extension Array where Element == CountdownEvent {
    
    func toCalendarEvents(in range: DateInterval) -> [CalendarEvent] {
        var results = [CalendarEvent]()
        for event in self {
            if let events = event.calendarEvents(in: range) {
                results.append(contentsOf: events)
            }
        }
    
        return results
    }
}

//
//  CountdownEvent+Calendar.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/23.
//

import Foundation

extension CountdownEvent {

    /// 日历事件（按 `calendarDisplayMode` 决定在区间内需要显示的天数）
    func calendarEvents(in range: DateInterval) -> [CalendarEvent]? {
        guard calendarDisplayMode != .none else {
            return nil
        }
        
        /// 过滤基准日期：
        /// - 正数事项：目标日期在过去，丢弃目标日期之前的日期（否则会因目标日已过而永不显示）
        /// - 倒数事项：目标日期在未来，丢弃今天之前的日期
        let referenceDate: Date
        switch effectiveCountingType {
        case .countUp:
            referenceDate = date.targetDate.startOfDay()
        case .countdown:
            referenceDate = Date().startOfDay()
        }
        
        /// 先按基准日期收缩查询区间，避免对基准日之前的日期做无效的窗口计算
        let startDate = max(range.start, referenceDate)
        guard startDate <= range.end else {
            return nil
        }
        
        let displayRange = DateInterval(start: startDate, end: range.end)
        
        /// 汇总显示窗口与收缩后区间相交的每一天（均不早于基准日期）
        var days = Set<Date>()
        for window in displayWindows(in: displayRange) {
            guard let clipped = window.intersection(with: displayRange) else {
                continue
            }
            
            clipped.enumerateDays { date in
                days.insert(date.startOfDay())
                return true
            }
        }
        
        guard days.count > 0 else {
            return nil
        }
        
        return days.sorted().map { calendarEvent(on: $0) }
    }
    
    /// 动态计算的生效计数类型
    ///
    /// 与编辑页的显隐条件保持一致（`CountdownGeneralEditSectionController.showsCountingTypeCellItem`）：
    /// 仅「目标日期已过去 + 存在重复规则」时，用户设置的 `countingType` 才有效；
    /// 其余情况（未来日期、或不重复）该属性会被忽略，统一按倒数（`countdown`）处理。
    var effectiveCountingType: CountingType {
        let isPastDate = date.targetDate < Date().startOfDay()
        let hasRepeat = timePlan.type != nil && timePlan.type != CountdownTimePlanType.none
        guard isPastDate, hasRepeat else {
            return .countdown
        }
        
        return countingType
    }
    
    // MARK: - Helpers
    /// 日历显示窗口
    private func displayWindows(in range: DateInterval) -> [DateInterval] {
        switch calendarDisplayMode {
        case .none:
            return []
        case .always:
            /// 一直显示：覆盖整个查询区间
            return [range]
        case .onTheDay:
            return occurrenceDates(from: range.start, to: range.end).map {
                DateInterval.rangeOfDay($0)
            }
        case .daysBefore(let days):
            let advanceDays = CountdownDisplayMode.validDays(days)
            /// 发生日最晚可超出区间 advanceDays 天，其显示窗口仍可能与区间相交
            let searchEnd = range.end.dateByAddingDays(advanceDays) ?? range.end
            return occurrenceDates(from: range.start, to: searchEnd).compactMap { occurrence in
                guard let startDate = occurrence.dateByAddingDays(-advanceDays) else {
                    return nil
                }
                
                return DateInterval(start: startDate.startOfDay(), end: occurrence.endOfDay())
            }
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
    private func calendarEvent(on date: Date) -> CalendarEvent {
        let interval = DateInterval.rangeOfDay(date)
        let event = CalendarEvent(identifier: identifier,
                                  source: .countdown,
                                  name: calendarDisplayTitle(on: date),
                                  color: color ?? type.color,
                                  startDate: interval.start,
                                  endDate: interval.end,
                                  isAllDay: true,
                                  isCompleted: false,
                                  sourceItem: self)
        return event
    }
    
    /// 日历中显示的名称（表情 + 名称 + 相对发生日期的说明）
    /// - Parameter date: 日历事项所在的日期
    func calendarDisplayTitle(on date: Date) -> String {
        let title = (emoji ?? type.emoji) + displayName
        guard let description = relativeDateDescription(on: date) else {
            return title
        }
        
        return title + " • " + description
    }
    
    /// 相对显示日期的说明
    ///
    /// - 倒数事项：`x天后` / `明天` / `今天`
    /// - 正数事项：`已过x天`
    /// - Parameter date: 日历事项所在的日期
    /// - Returns: 无有效差值时返回 `nil`
    private func relativeDateDescription(on date: Date) -> String? {
        switch effectiveCountingType {
        case .countdown:
            /// 显示日对应的下一个发生日（不重复时为目标日期本身）
            let occurrence = timePlan.nextPlanDate(from: date, startDate: self.date)?.targetDate
                ?? self.date.targetDate
            let days = Date.days(fromDate: date, toDate: occurrence)
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
            /// 距离起始日已经过去的天数
            let days = Date.days(fromDate: self.date.targetDate, toDate: date)
            guard days >= 0 else {
                return nil
            }
            
            if days == 0 {
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

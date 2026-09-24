//
//  CountdownEvent+MyDayEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/23.
//

import Foundation

extension CountdownEvent {

    /// 我的一天事件（按 `myDayDisplayMode` 决定在区间内需要显示的天数）
    func myDayEvents(in range: DateInterval) -> [MyDayEvent]? {
        guard myDayDisplayMode != .none else {
            return nil
        }
        
        /// 过滤基准日期
        /// - 正数事项：目标日期在过去，今天显示
        /// - 倒数事项：目标日期在未来，丢弃今天之前的日期
        let referenceRange: DateInterval?
        switch effectiveCountingType {
        case .countUp:
            let start = Date().startOfDay()
            referenceRange = DateInterval(start: start, end: start.endOfDay())
        case .countdown:
            referenceRange = DateInterval(start: Date().startOfDay(),
                                          end: .distantFuture)
        }
        
        referenceRange = referenceRange?.intersection(with: range)
        let occuranceRange = DateInterval(start: .distantPast, end: occuranceDate.targetDate)
        /// 先按基准日期收缩查询区间，避免对基准日之前的日期做无效的窗口计算
        guard let displayRange = referenceRange?.intersection(with: occuranceRange) else {
            return nil
        }
        
        let days = displayDays(in: displayRange, mode: myDayDisplayMode)
        guard days.count > 0 else {
            return nil
        }
        
        return days.map { myDayEvent(on: $0) }
    }
    
    // MARK: - Helpers
    /// 我的一天事件（倒数日为全天事项）
    private func myDayEvent(on day: Date) -> MyDayEvent {
        let interval = DateInterval.rangeOfDay(day)
        let event = MyDayEvent(identifier: identifier,
                               source: .countdown,
                               name: displayName,
                               color: color ?? type.color,
                               startDate: interval.start,
                               endDate: interval.end,
                               isAllDay: true,
                               isCompleted: false,
                               sourceItem: self)
        return event
    }
    
    /// 我的一天详情副标题（发生日期 + 相对说明），按显示日期计算
    func myDayDetail(on day: Date) -> ASAttributedString? {
        let option = CountdownEventDetailOption.allExceptMyDay
        let detailProvider = CountdownEventDetailProvider(event: self,
                                                          option: option,
                                                          day: day)
        return detailProvider.attributedInfo()
    }
}

// MARK: - Array 扩展
extension Array where Element == CountdownEvent {
    
    func toMyDayEvents(in range: DateInterval) -> [MyDayEvent] {
        var results = [MyDayEvent]()
        for event in self {
            if let events = event.myDayEvents(in: range) {
                results.append(contentsOf: events)
            }
        }
    
        return results
    }
}

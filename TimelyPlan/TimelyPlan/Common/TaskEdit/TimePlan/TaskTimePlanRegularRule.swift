//
//  TaskTimePlanRegularRule.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/27.
//

import Foundation

/// 定期规则结构体
struct TaskTimePlanRegularRule: Hashable, Codable, Equatable {
    
    /// 频率
    var frequency: RepeatFrequency = .daily
    
    /// 重复间隔
    var interval: Int = 1
    
    /// 与定期规则关联的周中的几天
    var daysOfTheWeek: [Weekday]?
    
    /// 与定期规则关联的月份中的几天,（1～31，-1表示最后一天）
    var daysOfTheMonth: [Int]?
    
    init() {}
    
    init(frequency: RepeatFrequency,
         interval: Int,
         daysOfTheWeek: [Weekday]?,
         daysOfTheMonth: [Int]?) {
        self.frequency = frequency
        self.interval = interval
        switch frequency {
        case .weekly:
            self.daysOfTheWeek = daysOfTheWeek
        case .monthly:
            self.daysOfTheMonth = daysOfTheMonth
        default:
            break
        }
    }
}

/// 定期规则描述
extension TaskTimePlanRegularRule: AttributedDescriptable {
    
    /// 描述标题
    var title: String? {
        return intervalDescription?.value.string.capitalizedFirstLetter()
    }
    
    /// 副标题
    var subtitle: String? {
        return detailDescription?.value.string.capitalizedFirstLetter()
    }
    
    func localizedAttributedDescription() -> ASAttributedString? {
        var descriptions = [ASAttributedString]()
        if let intervalDescription = intervalDescription {
            descriptions.append(intervalDescription)
        }
        
        if let detailDescription = detailDescription {
            descriptions.append(detailDescription)
        }
        
        return descriptions.joined(separator: ", ")
    }
    
    // MARK: - Interval
    var intervalDescription: ASAttributedString? {
        return intervalDescription(interval: interval, frequency: frequency)
    }
    
    func intervalDescription(interval: Int, frequency: RepeatFrequency) -> ASAttributedString? {
        let frequencyFormat: String = resGetString("every %@")
        return .string(format: frequencyFormat, attributedParameters: [intervalAttributedString])
    }
    
    private var intervalAttributedString: ASAttributedString {
        let unit = frequency.unit(for: interval).lowercased()
        var string: String
        if interval == 1 {
            string = resGetString(unit)
        } else {
            let format: String = resGetString("%ld \(unit)")
            string = String(format: format, interval)
        }
        
        return "\(string, highlightedTextColor)"
    }
        
    // MARK: - Detail
    /// 定期详细描述信息
    var detailDescription: ASAttributedString? {
        switch frequency {
        case .daily:
            return nil
        case .weekly:
            return daysOfTheWeekDescription
        case .monthly:
            return daysOfTheMonthDescription
        default:
            return nil
        }
    }
    
    /// 周天
    var daysOfTheWeekDescription: ASAttributedString? {
        guard let symbols = daysOfTheWeek?.orderedShortSymbols else {
            return nil
        }
        
        let symbolString = symbols.joined(separator: ", ")
        let symbolAttributedString: ASAttributedString = "\(symbolString, highlightedTextColor)"
        let format: String = resGetString("on the %@")
        return .string(format: format, attributedParameters: [symbolAttributedString])
    }

    /// 月天
    var daysOfTheMonthDescription: ASAttributedString? {
        guard let daysOfTheMonth = daysOfTheMonth, daysOfTheMonth.count > 0 else {
            return nil
        }

        var symbols = [String]()
        for i in 1...31 {
           if daysOfTheMonth.contains(i) {
               let format = Date.ordinalSymbol(dayOfTheMonth: i)
               let symbol = String(format: resGetString(format), i)
               symbols.append(symbol)
           }
        }

        // 最后一天
        if daysOfTheMonth.contains(-1) {
            let lastSymbol: String = resGetString("last day")
            symbols.append(lastSymbol)
        }
        
        let symbolString = symbols.joined(separator: ", ")
        let symbolAttributedString: ASAttributedString = "\(symbolString, highlightedTextColor)"
        let format: String = resGetString("on the %@")
        
        return .string(format: format, attributedParameters: [symbolAttributedString])
    }
}

extension TaskTimePlanRegularRule {
    
    /// 获取特定日期之后（包括当天）最近的一个计划日
    /// - Parameters:
    ///   - date: 参考日期
    ///   - startDate: 习惯开始日期
    ///   - endDate: 习惯结束日期（nil表示永不结束）
    /// - Returns: 最近的下一个计划日，如果找不到返回nil
    func nextPlanDate(from date: Date, startDate: Date, endDate: Date? = nil) -> Date? {
        let rule = self
        let calendar = Calendar.current
        let referenceDate = max(calendar.startOfDay(for: date), calendar.startOfDay(for: startDate))
        
        let nextDate: Date?
        switch rule.frequency {
        case .daily:
            nextDate = nextDailyDate(from: referenceDate, interval: max(1, rule.interval), startDate: startDate, calendar: calendar)
            
        case .weekly:
            nextDate = nextWeeklyDate(from: referenceDate, daysOfWeek: rule.daysOfTheWeek, startDate: startDate, calendar: calendar)
            
        case .monthly:
            nextDate = nextMonthlyDate(from: referenceDate, daysOfMonth: rule.daysOfTheMonth, startDate: startDate, calendar: calendar)
            
        case .yearly:
            nextDate = nil
        }
        
        guard let nextDate = nextDate else { return nil }
        
        if let endDate = endDate {
            return nextDate <= calendar.startOfDay(for: endDate) ? nextDate : nil
        }
        
        return nextDate
    }
    
    // MARK: - Daily (O(1))
    
    private func nextDailyDate(from date: Date, interval: Int, startDate: Date, calendar: Calendar) -> Date? {
        let daysFromStart = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        
        if daysFromStart % interval == 0 {
            return date
        } else {
            let daysToAdd = interval - (daysFromStart % interval)
            return calendar.date(byAdding: .day, value: daysToAdd, to: date)
        }
    }
    
    // MARK: - Weekly (O(1))

    private func nextWeeklyDate(from date: Date, daysOfWeek: [Weekday]?, startDate: Date, calendar: Calendar) -> Date? {
        let targetDays = (daysOfWeek?.isEmpty ?? true)
            ? [Weekday(rawValue: calendar.component(.weekday, from: startDate))!]
            : daysOfWeek!
        
        let currentWeekday = calendar.component(.weekday, from: date)
        let sortedDays = targetDays.map { $0.rawValue }.sorted()
        
        // 查找最近的下一个目标星期几（包括今天）
        var minDaysToAdd: Int?
        
        for weekday in sortedDays {
            var daysToAdd = weekday - currentWeekday
            
            // 如果小于0，说明是下周的日期
            if daysToAdd < 0 {
                daysToAdd += 7
            }
            
            // 找最小的正数或0（包括今天）
            if minDaysToAdd == nil || daysToAdd < minDaysToAdd! {
                minDaysToAdd = daysToAdd
            }
        }
        
        // 如果本周有合适的日期
        if let daysToAdd = minDaysToAdd {
            return calendar.date(byAdding: .day, value: daysToAdd, to: date)
        }
        
        // 如果本周没有（不太可能发生），返回下周第一个
        if let firstWeekday = sortedDays.first {
            let daysToAdd = 7 - currentWeekday + firstWeekday
            return calendar.date(byAdding: .day, value: daysToAdd, to: date)
        }
        
        return nil
    }
    
    // MARK: - Monthly (O(n), n为daysOfMonth数量)
    
    private func nextMonthlyDate(from date: Date, daysOfMonth: [Int]?, startDate: Date, calendar: Calendar) -> Date? {
        let targetDays = (daysOfMonth?.isEmpty ?? true)
            ? [calendar.component(.day, from: startDate)]
            : daysOfMonth!
        
        let currentDay = calendar.component(.day, from: date)
        var components = calendar.dateComponents([.year, .month], from: date)
        
        // 获取当月天数
        guard let monthStart = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else { return nil }
        let daysInMonth = range.count
        
        // 查找当月内剩余的目标日期
        let sortedDays = targetDays.map { resolveDay($0, daysInMonth: daysInMonth) }.sorted()
        
        for day in sortedDays where day >= currentDay {
            components.day = day
            if let candidateDate = calendar.date(from: components) {
                return candidateDate
            }
        }
        
        // 查找下个月
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart) {
            var nextComponents = calendar.dateComponents([.year, .month], from: nextMonth)
            guard let nextRange = calendar.range(of: .day, in: .month, for: nextMonth) else { return nil }
            let nextDaysInMonth = nextRange.count
            
            let nextSortedDays = targetDays.map { resolveDay($0, daysInMonth: nextDaysInMonth) }.sorted()
            if let firstDay = nextSortedDays.first {
                nextComponents.day = firstDay
                return calendar.date(from: nextComponents)
            }
        }
        
        return nil
    }
    
    /// 处理特殊日期值（-1表示最后一天，超出范围取最后一天）
    private func resolveDay(_ day: Int, daysInMonth: Int) -> Int {
        if day == -1 { return daysInMonth }
        return min(day, daysInMonth)
    }
}

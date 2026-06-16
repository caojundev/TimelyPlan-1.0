//
//  RecurrenceDateCalculator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/16.
//

import Foundation

/// 重复日期计算器
class RecurrenceDateCalculator {
    
    private let calendar = Calendar.current
    
    // MARK: - 公共方法
    
    /// 计算指定日期范围内的所有重复日期
    func calculateOccurrences(
        startDate: Date,
        repeatRule: RepeatRule,
        fromDate: Date,
        toDate: Date
    ) -> [Date] {
        
        // 边界检查
        guard fromDate <= toDate else { return [] }
        guard let type = repeatRule.type, type != .none else {
            // 不重复，检查开始日期是否在范围内
            if startDate >= fromDate && startDate <= toDate {
                return isDateValid(startDate, repeatRule: repeatRule) ? [startDate] : []
            }
            return []
        }
        
        // 处理特定日期类型
        if let recurrenceRule = repeatRule.recurrenceRule,
           recurrenceRule.type == .specificDates,
           let specificDates = recurrenceRule.specificDates {
            let filtered = specificDates
                .filter { date in
                    date >= fromDate &&
                    date <= toDate &&
                    date >= startDate &&
                    isDateValid(date, repeatRule: repeatRule)
                }
                .sorted()
            
            // 应用重复次数限制
            if let end = repeatRule.end, case .count = end.type,
               let maxCount = end.occurrenceCount {
                return Array(filtered.prefix(maxCount))
            }
            return filtered
        }
        
        // 获取第一个在范围内的日期
        guard let firstDate = findFirstOccurrence(
            startDate: startDate,
            repeatRule: repeatRule,
            fromDate: fromDate
        ) else { return [] }
        
        // 确保第一个日期在范围内
        if firstDate > toDate { return [] }
        if firstDate < fromDate { return [] }
        
        // 检查第一个日期是否有效
        if !isDateValid(firstDate, repeatRule: repeatRule) {
            return []
        }
        
        // 从第一个日期开始，依次计算后续日期
        var occurrences: [Date] = [firstDate]
        
        // 检查是否达到重复次数限制
        if let end = repeatRule.end, case .count = end.type {
            if let maxCount = end.occurrenceCount, maxCount <= 1 {
                return occurrences
            }
        }
        
        var currentDate = firstDate
        
        while true {
            guard let nextDate = findNextOccurrence(
                currentDate: currentDate,
                startDate: startDate,
                repeatRule: repeatRule
            ) else { break }
            
            // 严格检查边界条件
            if nextDate > toDate { break }
            if nextDate < fromDate { continue } // 跳过不在范围内的日期
            
            // 检查日期有效性（包括endDate）
            if !isDateValid(nextDate, repeatRule: repeatRule) {
                break // 如果超过endDate，停止计算
            }
            
            // 检查重复次数限制
            if let end = repeatRule.end, case .count = end.type {
                if let maxCount = end.occurrenceCount,
                   occurrences.count >= maxCount {
                    break
                }
            }
            
            occurrences.append(nextDate)
            currentDate = nextDate
        }
        
        return occurrences
    }
    
    /// 计算指定日期之后最近的一个重复日期
    func findNextOccurrenceAfter(
        startDate: Date,
        repeatRule: RepeatRule,
        afterDate: Date
    ) -> Date? {
        guard let type = repeatRule.type, type != .none else {
            if startDate > afterDate && isDateValid(startDate, repeatRule: repeatRule) {
                return startDate
            }
            return nil
        }
        
        let result = findFirstOccurrence(
            startDate: startDate,
            repeatRule: repeatRule,
            fromDate: max(startDate, afterDate.addingTimeInterval(1))
        )
        
        // 确保返回的日期在afterDate之后且有效
        if let result = result, result > afterDate, isDateValid(result, repeatRule: repeatRule) {
            return result
        }
        
        return nil
    }
    
    // MARK: - 私有方法
    
    /// 找到从指定日期开始的第一个重复日期
    private func findFirstOccurrence(
        startDate: Date,
        repeatRule: RepeatRule,
        fromDate: Date
    ) -> Date? {
        guard let type = repeatRule.type else { return nil }
        
        // 对于特定日期类型，直接查找
        if let recurrenceRule = repeatRule.recurrenceRule,
           recurrenceRule.type == .specificDates,
           let specificDates = recurrenceRule.specificDates {
            return specificDates
                .filter { $0 >= fromDate && $0 >= startDate && isDateValid($0, repeatRule: repeatRule) }
                .min()
        }
        
        // 对于定期类型，计算第一个在范围内的日期
        return calculateFirstRegularOccurrence(
            startDate: startDate,
            repeatRule: repeatRule,
            fromDate: max(startDate, fromDate)
        )
    }
    
    /// 计算定期重复的第一个在范围内的日期
    private func calculateFirstRegularOccurrence(
        startDate: Date,
        repeatRule: RepeatRule,
        fromDate: Date
    ) -> Date? {
        guard let type = repeatRule.type,
              let recurrenceRule = repeatRule.recurrenceRule else { return nil }
        
        let frequency = recurrenceRule.frequency ?? .daily
        let interval = max(1, recurrenceRule.interval ?? 1)
        
        // 如果开始日期已经在范围内，先检查它是否有效
        if startDate >= fromDate && isDateValid(startDate, repeatRule: repeatRule) {
            return startDate
        }
        
        switch type {
        case .daily:
            return findFirstDailyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, repeatRule: repeatRule)
            
        case .weekly:
            return findFirstWeeklyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, recurrenceRule: recurrenceRule, repeatRule: repeatRule)
            
        case .weekday:
            return findFirstWeekdayOccurrence(startDate: startDate, fromDate: fromDate, repeatRule: repeatRule)
            
        case .weekend:
            return findFirstWeekendOccurrence(startDate: startDate, fromDate: fromDate, repeatRule: repeatRule)
            
        case .monthly:
            return findFirstMonthlyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, recurrenceRule: recurrenceRule, repeatRule: repeatRule)
            
        case .yearly:
            return findFirstYearlyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, recurrenceRule: recurrenceRule, repeatRule: repeatRule)
            
        case .lunarYearly:
            return findFirstLunarYearlyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, repeatRule: repeatRule)
            
        case .legalWorkday:
            return findFirstLegalWorkdayOccurrence(startDate: startDate, fromDate: fromDate, repeatRule: repeatRule)
            
        case .ebbinghaus:
            return findFirstEbbinghausOccurrence(startDate: startDate, fromDate: fromDate, repeatRule: repeatRule)
            
        case .custom:
            return calculateCustomFirstOccurrence(startDate: startDate, fromDate: fromDate, recurrenceRule: recurrenceRule, repeatRule: repeatRule)
            
        default:
            return nil
        }
    }
    
    /// 计算下一个重复日期
    private func findNextOccurrence(
        currentDate: Date,
        startDate: Date,
        repeatRule: RepeatRule
    ) -> Date? {
        guard let type = repeatRule.type,
              let recurrenceRule = repeatRule.recurrenceRule else { return nil }
        
        let frequency = recurrenceRule.frequency ?? .daily
        let interval = max(1, recurrenceRule.interval ?? 1)
        
        switch type {
        case .daily:
            return calculateNextDailyOccurrence(currentDate: currentDate, interval: interval)
            
        case .weekly:
            return calculateNextWeeklyOccurrence(currentDate: currentDate, interval: interval, recurrenceRule: recurrenceRule)
            
        case .weekday:
            return calculateNextWeekdayOccurrence(currentDate: currentDate)
            
        case .weekend:
            return calculateNextWeekendOccurrence(currentDate: currentDate)
            
        case .monthly:
            return calculateNextMonthlyOccurrence(currentDate: currentDate, interval: interval, recurrenceRule: recurrenceRule)
            
        case .yearly:
            return calculateNextYearlyOccurrence(currentDate: currentDate, interval: interval, recurrenceRule: recurrenceRule)
            
        case .lunarYearly:
            return calculateNextLunarYearlyOccurrence(currentDate: currentDate, interval: interval)
            
        case .legalWorkday:
            return calculateNextLegalWorkdayOccurrence(currentDate: currentDate)
            
        case .ebbinghaus:
            return calculateNextEbbinghausOccurrence(currentDate: currentDate, startDate: startDate)
            
        case .custom:
            return calculateCustomNextOccurrence(currentDate: currentDate, recurrenceRule: recurrenceRule)
            
        default:
            return nil
        }
    }
    
    // MARK: - 每日重复计算
    
    private func findFirstDailyOccurrence(
        startDate: Date,
        fromDate: Date,
        interval: Int,
        repeatRule: RepeatRule
    ) -> Date? {
        if startDate >= fromDate && isDateValid(startDate, repeatRule: repeatRule) {
            return startDate
        }
        
        // 计算需要跳过的天数
        let daysDiff = calendar.dateComponents([.day], from: startDate, to: fromDate).day ?? 0
        let skipCount = max(0, Int(ceil(Double(daysDiff) / Double(interval))))
        let candidate = calendar.date(byAdding: .day, value: skipCount * interval, to: startDate)!
        
        // 确保候选日期 >= fromDate
        if candidate < fromDate {
            return calendar.date(byAdding: .day, value: interval, to: candidate)
        }
        
        return isDateValid(candidate, repeatRule: repeatRule) ? candidate : nil
    }
    
    private func calculateNextDailyOccurrence(currentDate: Date, interval: Int) -> Date? {
        return calendar.date(byAdding: .day, value: interval, to: currentDate)
    }
    
    // MARK: - 每周重复计算
    
    private func findFirstWeeklyOccurrence(
        startDate: Date,
        fromDate: Date,
        interval: Int,
        recurrenceRule: RecurrenceRule,
        repeatRule: RepeatRule
    ) -> Date? {
        let targetWeekdays = getTargetWeekdays(from: recurrenceRule, startDate: startDate)
        
        // 先检查开始日期是否在范围内且是目标工作日
        if startDate >= fromDate && isDateValid(startDate, repeatRule: repeatRule) {
            let startWeekday = calendar.component(.weekday, from: startDate)
            if let dayOfWeek = Weekday(rawValue: startWeekday),
               targetWeekdays.contains(dayOfWeek) {
                return startDate
            }
        }
        
        // 计算从开始日期所在周的第一天到目标日期的周数
        let startWeekStart = startOfWeek(startDate)
        let fromWeekStart = startOfWeek(fromDate)
        let weeksDiff = calendar.dateComponents([.weekOfYear], from: startWeekStart, to: fromWeekStart).weekOfYear ?? 0
        let skipWeeks = max(0, Int(ceil(Double(weeksDiff) / Double(interval))))
        let baseWeekStart = calendar.date(byAdding: .weekOfYear, value: skipWeeks * interval, to: startWeekStart)!
        
        // 从基准周开始查找，确保日期 >= fromDate
        var currentWeekStart = baseWeekStart
        var candidate: Date? = nil
        
        // 最多查找10周，避免无限循环
        for _ in 0..<10 {
            candidate = findNextMatchingWeekday(from: max(currentWeekStart, fromDate),
                                                targetWeekdays: targetWeekdays,
                                                repeatRule: repeatRule)
            
            if let candidate = candidate, candidate >= fromDate, isDateValid(candidate, repeatRule: repeatRule) {
                return candidate
            }
            
            currentWeekStart = calendar.date(byAdding: .weekOfYear, value: interval, to: currentWeekStart)!
            
            // 如果已经超出合理范围，停止查找
            if currentWeekStart > calendar.date(byAdding: .year, value: 1, to: fromDate)! {
                break
            }
        }
        
        return nil
    }
    
    private func calculateNextWeeklyOccurrence(
        currentDate: Date,
        interval: Int,
        recurrenceRule: RecurrenceRule
    ) -> Date? {
        let targetWeekdays = getTargetWeekdays(from: recurrenceRule, startDate: currentDate)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        
        // 如果间隔大于1，可能需要跳到下一周
        if interval > 1 && targetWeekdays.count == 1 {
            let currentWeekStart = startOfWeek(currentDate)
            let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: interval, to: currentWeekStart)!
            return findNextMatchingWeekday(from: nextWeekStart, targetWeekdays: targetWeekdays)
        }
        
        // 在当前周内查找下一个匹配的工作日
        if let nextInWeek = findNextMatchingWeekdayInSameWeek(from: nextDay, targetWeekdays: targetWeekdays) {
            return nextInWeek
        }
        
        // 跳到下一周的第一个匹配工作日
        let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: interval, to: startOfWeek(currentDate))!
        return findNextMatchingWeekday(from: nextWeekStart, targetWeekdays: targetWeekdays)
    }
    
    // MARK: - 工作日重复计算
    
    private func findFirstWeekdayOccurrence(
        startDate: Date,
        fromDate: Date,
        repeatRule: RepeatRule
    ) -> Date? {
        if startDate >= fromDate && isWeekday(startDate) && isDateValid(startDate, repeatRule: repeatRule) {
            return startDate
        }
        
        let searchStart = max(startDate, fromDate)
        return findNextWeekday(from: searchStart.addingTimeInterval(-86400), repeatRule: repeatRule)
    }
    
    private func calculateNextWeekdayOccurrence(currentDate: Date) -> Date? {
        return findNextWeekday(from: currentDate)
    }
    
    // MARK: - 周末重复计算
    
    private func findFirstWeekendOccurrence(
        startDate: Date,
        fromDate: Date,
        repeatRule: RepeatRule
    ) -> Date? {
        if startDate >= fromDate && isWeekend(startDate) && isDateValid(startDate, repeatRule: repeatRule) {
            return startDate
        }
        
        let searchStart = max(startDate, fromDate)
        return findNextWeekend(from: searchStart.addingTimeInterval(-86400), repeatRule: repeatRule)
    }
    
    private func calculateNextWeekendOccurrence(currentDate: Date) -> Date? {
        return findNextWeekend(from: currentDate)
    }
    
    // MARK: - 每月重复计算
    
    private func findFirstMonthlyOccurrence(
        startDate: Date,
        fromDate: Date,
        interval: Int,
        recurrenceRule: RecurrenceRule,
        repeatRule: RepeatRule
    ) -> Date? {
        if startDate >= fromDate && isDateValid(startDate, repeatRule: repeatRule) {
            return startDate
        }
        
        // 计算需要跳过的月数
        let startMonthStart = startOfMonth(startDate)
        let fromMonthStart = startOfMonth(fromDate)
        let monthsDiff = calendar.dateComponents([.month], from: startMonthStart, to: fromMonthStart).month ?? 0
        let skipMonths = max(0, Int(ceil(Double(monthsDiff) / Double(interval))))
        let baseMonthStart = calendar.date(byAdding: .month, value: skipMonths * interval, to: startMonthStart)!
        
        // 从基准月开始查找
        var currentMonthStart = baseMonthStart
        
        for _ in 0..<12 { // 最多查找12个月
            if let candidate = findFirstValidDateInMonth(from: max(currentMonthStart, fromDate),
                                                         recurrenceRule: recurrenceRule,
                                                         repeatRule: repeatRule),
               candidate >= fromDate,
               isDateValid(candidate, repeatRule: repeatRule) {
                return candidate
            }
            
            currentMonthStart = calendar.date(byAdding: .month, value: interval, to: currentMonthStart)!
            
            // 防止无限循环
            if currentMonthStart > calendar.date(byAdding: .year, value: 1, to: fromDate)! {
                break
            }
        }
        
        return nil
    }
    
    private func calculateNextMonthlyOccurrence(
        currentDate: Date,
        interval: Int,
        recurrenceRule: RecurrenceRule
    ) -> Date? {
        let nextMonth = calendar.date(byAdding: .month, value: interval, to: currentDate)!
        return findFirstValidDateInMonth(from: nextMonth, recurrenceRule: recurrenceRule)
    }
    
    // MARK: - 每年重复计算
    
    private func findFirstYearlyOccurrence(
        startDate: Date,
        fromDate: Date,
        interval: Int,
        recurrenceRule: RecurrenceRule,
        repeatRule: RepeatRule
    ) -> Date? {
        if startDate >= fromDate && isDateValid(startDate, repeatRule: repeatRule) {
            return startDate
        }
        
        // 计算需要跳过的年数
        let yearsDiff = calendar.dateComponents([.year], from: startDate, to: fromDate).year ?? 0
        let skipYears = max(0, Int(ceil(Double(yearsDiff) / Double(interval))))
        let candidate = calendar.date(byAdding: .year, value: skipYears * interval, to: startDate)!
        
        // 确保候选日期 >= fromDate
        if candidate < fromDate {
            return calendar.date(byAdding: .year, value: interval, to: candidate)
        }
        
        return isDateValid(candidate, repeatRule: repeatRule) ? candidate : nil
    }
    
    private func calculateNextYearlyOccurrence(currentDate: Date, interval: Int, recurrenceRule: RecurrenceRule) -> Date? {
        return calendar.date(byAdding: .year, value: interval, to: currentDate)
    }
    
    // MARK: - 农历每年重复计算
    
    private func findFirstLunarYearlyOccurrence(
        startDate: Date,
        fromDate: Date,
        interval: Int,
        repeatRule: RepeatRule
    ) -> Date? {
        // 简化实现：使用公历近似农历
        return findFirstYearlyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, recurrenceRule: RecurrenceRule(), repeatRule: repeatRule)
    }
    
    private func calculateNextLunarYearlyOccurrence(currentDate: Date, interval: Int) -> Date? {
        return calendar.date(byAdding: .year, value: interval, to: currentDate)
    }
    
    // MARK: - 法定工作日重复计算
    
    private func findFirstLegalWorkdayOccurrence(
        startDate: Date,
        fromDate: Date,
        repeatRule: RepeatRule
    ) -> Date? {
        // 简化实现：假设周一至周五为法定工作日
        return findFirstWeekdayOccurrence(startDate: startDate, fromDate: fromDate, repeatRule: repeatRule)
    }
    
    private func calculateNextLegalWorkdayOccurrence(currentDate: Date) -> Date? {
        return calculateNextWeekdayOccurrence(currentDate: currentDate)
    }
    
    // MARK: - 艾宾浩斯遗忘曲线重复计算
    
    private let ebbinghausIntervals = [1, 2, 4, 7, 15, 30]
    
    private func findFirstEbbinghausOccurrence(
        startDate: Date,
        fromDate: Date,
        repeatRule: RepeatRule
    ) -> Date? {
        if startDate >= fromDate && isDateValid(startDate, repeatRule: repeatRule) {
            return startDate
        }
        
        // 计算所有可能的重复日期
        var cumulativeDays = 0
        var intervalIndex = 0
        
        for _ in 0..<50 { // 限制最大计算次数
            let interval: Int
            if intervalIndex < ebbinghausIntervals.count {
                interval = ebbinghausIntervals[intervalIndex]
                intervalIndex += 1
            } else {
                interval = 30
            }
            
            cumulativeDays += interval
            if let nextDate = calendar.date(byAdding: .day, value: cumulativeDays, to: startDate) {
                if nextDate >= fromDate && isDateValid(nextDate, repeatRule: repeatRule) {
                    return nextDate
                }
            }
        }
        
        return nil
    }
    
    private func calculateNextEbbinghausOccurrence(currentDate: Date, startDate: Date) -> Date? {
        let daysFromStart = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
        
        var cumulativeDays = 0
        var intervalIndex = 0
        
        while cumulativeDays <= daysFromStart + 365 { // 限制最大天数
            let interval: Int
            if intervalIndex < ebbinghausIntervals.count {
                interval = ebbinghausIntervals[intervalIndex]
                intervalIndex += 1
            } else {
                interval = 30
            }
            
            cumulativeDays += interval
            if cumulativeDays > daysFromStart {
                return calendar.date(byAdding: .day, value: cumulativeDays, to: startDate)
            }
        }
        
        return nil
    }
    
    // MARK: - 自定义重复计算
    
    private func calculateCustomFirstOccurrence(
        startDate: Date,
        fromDate: Date,
        recurrenceRule: RecurrenceRule,
        repeatRule: RepeatRule
    ) -> Date? {
        guard let frequency = recurrenceRule.frequency else { return nil }
        let interval = max(1, recurrenceRule.interval ?? 1)
        
        switch frequency {
        case .daily:
            return findFirstDailyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, repeatRule: repeatRule)
        case .weekly:
            return findFirstWeeklyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, recurrenceRule: recurrenceRule, repeatRule: repeatRule)
        case .monthly:
            return findFirstMonthlyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, recurrenceRule: recurrenceRule, repeatRule: repeatRule)
        case .yearly:
            return findFirstYearlyOccurrence(startDate: startDate, fromDate: fromDate, interval: interval, recurrenceRule: recurrenceRule, repeatRule: repeatRule)
        }
    }
    
    private func calculateCustomNextOccurrence(
        currentDate: Date,
        recurrenceRule: RecurrenceRule
    ) -> Date? {
        guard let frequency = recurrenceRule.frequency else { return nil }
        let interval = max(1, recurrenceRule.interval ?? 1)
        
        switch frequency {
        case .daily:
            return calculateNextDailyOccurrence(currentDate: currentDate, interval: interval)
        case .weekly:
            return calculateNextWeeklyOccurrence(currentDate: currentDate, interval: interval, recurrenceRule: recurrenceRule)
        case .monthly:
            return calculateNextMonthlyOccurrence(currentDate: currentDate, interval: interval, recurrenceRule: recurrenceRule)
        case .yearly:
            return calculateNextYearlyOccurrence(currentDate: currentDate, interval: interval, recurrenceRule: recurrenceRule)
        }
    }
    
    // MARK: - 辅助方法
    
    private func getTargetWeekdays(from rule: RecurrenceRule, startDate: Date) -> [Weekday] {
        if let daysOfWeek = rule.daysOfTheWeek, !daysOfWeek.isEmpty {
            return daysOfWeek.map { $0.dayOfTheWeek }
        }
        let weekday = calendar.component(.weekday, from: startDate)
        if let dayOfWeek = Weekday(rawValue: weekday) {
            return [dayOfWeek]
        }
        return []
    }
    
    private func findNextMatchingWeekday(from date: Date, targetWeekdays: [Weekday], repeatRule: RepeatRule? = nil) -> Date? {
        var currentDate = date
        let maxIterations = 14
        
        for _ in 0..<maxIterations {
            let weekday = calendar.component(.weekday, from: currentDate)
            if let dayOfWeek = Weekday(rawValue: weekday),
               targetWeekdays.contains(dayOfWeek) {
                if let rule = repeatRule {
                    if isDateValid(currentDate, repeatRule: rule) {
                        return currentDate
                    }
                } else {
                    return currentDate
                }
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return nil
    }
    
    private func findNextMatchingWeekdayInSameWeek(from date: Date, targetWeekdays: [Weekday]) -> Date? {
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: startOfWeek(date))!
        var currentDate = date
        
        while currentDate <= weekEnd {
            let weekday = calendar.component(.weekday, from: currentDate)
            if let dayOfWeek = Weekday(rawValue: weekday),
               targetWeekdays.contains(dayOfWeek) {
                return currentDate
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return nil
    }
    
    private func findNextWeekday(from date: Date, repeatRule: RepeatRule? = nil) -> Date? {
        var currentDate = calendar.date(byAdding: .day, value: 1, to: date)!
        let maxIterations = 7
        
        for _ in 0..<maxIterations {
            if isWeekday(currentDate) {
                if let rule = repeatRule {
                    if isDateValid(currentDate, repeatRule: rule) {
                        return currentDate
                    }
                } else {
                    return currentDate
                }
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return nil
    }
    
    private func findNextWeekend(from date: Date, repeatRule: RepeatRule? = nil) -> Date? {
        var currentDate = calendar.date(byAdding: .day, value: 1, to: date)!
        let maxIterations = 7
        
        for _ in 0..<maxIterations {
            if isWeekend(currentDate) {
                if let rule = repeatRule {
                    if isDateValid(currentDate, repeatRule: rule) {
                        return currentDate
                    }
                } else {
                    return currentDate
                }
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return nil
    }
    
    private func findFirstValidDateInMonth(from date: Date, recurrenceRule: RecurrenceRule, repeatRule: RepeatRule? = nil) -> Date? {
        let monthlyMode = recurrenceRule.monthlyMode
        
        switch monthlyMode {
        case .onDays:
            return findFirstDayOfMonth(from: date, daysOfMonth: recurrenceRule.daysOfTheMonth, repeatRule: repeatRule)
        case .onWeek:
            return findFirstWeekOfMonth(from: date, daysOfWeek: recurrenceRule.daysOfTheWeek, repeatRule: repeatRule)
        }
    }
    
    private func findFirstDayOfMonth(from date: Date, daysOfMonth: [Int]?, repeatRule: RepeatRule? = nil) -> Date? {
        let targetDays = daysOfMonth ?? [calendar.component(.day, from: date)]
        
        for day in targetDays.sorted() {
            if let candidate = getDateInMonth(date: date, day: day),
               candidate >= date {
                if let rule = repeatRule {
                    if isDateValid(candidate, repeatRule: rule) {
                        return candidate
                    }
                } else {
                    return candidate
                }
            }
        }
        
        // 如果当月没有匹配的日期，返回下个月的第一个匹配日期
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: date) {
            return findFirstDayOfMonth(from: nextMonth, daysOfMonth: daysOfMonth, repeatRule: repeatRule)
        }
        
        return nil
    }
    
    private func findFirstWeekOfMonth(from date: Date, daysOfWeek: [RepeatDayOfWeek]?, repeatRule: RepeatRule? = nil) -> Date? {
        guard let daysOfWeek = daysOfWeek, !daysOfWeek.isEmpty else {
            let weekNumber = calendar.component(.weekOfMonth, from: date)
            let weekday = calendar.component(.weekday, from: date)
            let repeatDayOfWeek = RepeatDayOfWeek(
                dayOfTheWeek: Weekday(rawValue: weekday) ?? .monday,
                weekNumber: weekNumber
            )
            return findSpecificWeekdayInMonth(date: date, dayOfWeek: repeatDayOfWeek)
        }
        
        for dayOfWeek in daysOfWeek {
            if let candidate = findSpecificWeekdayInMonth(date: date, dayOfWeek: dayOfWeek),
               candidate >= date {
                if let rule = repeatRule {
                    if isDateValid(candidate, repeatRule: rule) {
                        return candidate
                    }
                } else {
                    return candidate
                }
            }
        }
        
        return nil
    }
    
    private func findSpecificWeekdayInMonth(date: Date, dayOfWeek: RepeatDayOfWeek) -> Date? {
        let monthStart = startOfMonth(date)
        let targetWeekday = dayOfWeek.dayOfTheWeek.rawValue
        var weekNumber = dayOfWeek.weekNumber
        
        if weekNumber == -1 { // 最后一周
            let monthEnd = endOfMonth(date)
            var currentDate = monthEnd
            
            while currentDate >= monthStart {
                let weekday = calendar.component(.weekday, from: currentDate)
                if weekday == targetWeekday {
                    return currentDate
                }
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            }
        } else {
            var currentDate = monthStart
            var foundWeeks = 0
            
            while currentDate <= endOfMonth(date) {
                let weekday = calendar.component(.weekday, from: currentDate)
                if weekday == targetWeekday {
                    foundWeeks += 1
                    if foundWeeks == weekNumber {
                        return currentDate
                    }
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }
        
        return nil
    }
    
    private func getDateInMonth(date: Date, day: Int) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: date)
        
        if day == -1 { // 最后一天
            let monthEnd = endOfMonth(date)
            components.day = calendar.component(.day, from: monthEnd)
        } else {
            components.day = day
        }
        
        return calendar.date(from: components)
    }
    
    // MARK: - 日期有效性检查
    
    /// 检查日期是否有效（修改后的版本，正确处理边界条件）
    private func isDateValid(_ date: Date, repeatRule: RepeatRule) -> Bool {
        guard let end = repeatRule.end else { return true }
        
        switch end.type {
        case .never:
            return true
        case .date:
            if let endDate = end.endDate {
                // 修正：应该包含结束日期当天
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
                return date <= endOfDay
            }
            return true
        case .count:
            // 次数限制在调用方处理
            return true
        }
    }
    
    // MARK: - 日期判断辅助方法
    
    private func isWeekday(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday >= 2 && weekday <= 6
    }
    
    private func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }
    
    private func startOfWeek(_ date: Date) -> Date {
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = calendar.firstWeekday
        return calendar.date(from: components)!
    }
    
    private func startOfMonth(_ date: Date) -> Date {
        var components = calendar.dateComponents([.year, .month], from: date)
        components.day = 1
        return calendar.date(from: components)!
    }
    
    private func endOfMonth(_ date: Date) -> Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return calendar.date(byAdding: components, to: startOfMonth(date))!
    }
}

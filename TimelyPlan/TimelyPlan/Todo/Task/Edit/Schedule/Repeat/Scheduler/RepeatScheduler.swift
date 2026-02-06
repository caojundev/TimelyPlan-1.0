//
//  RepeatScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/3.
//

import Foundation

class RepeatScheduler {
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday
    
    /// 根据开始日期，获取匹配重复规则在特定月所有的重复日日期数组
    func repeatDates(inMonthOf monthDate: Date, matching repeatRule: RepeatRule, startDate: Date) -> [Date]? {
        let firstMonthDay = monthDate.firstDayOfMonth()
        let monthDaysCount = monthDate.numberOfDaysInMonth()
        let endDate = endDate(of: repeatRule, startDate: startDate)
        var repeatDates = [Date]()
        for i in 0..<monthDaysCount {
            guard let date = firstMonthDay.dateByAddingDays(i) else {
                continue
            }
            
            let isRepeatDate = isRepeatDate(date, matching: repeatRule, startDate: startDate, endDate: endDate)
            if isRepeatDate {
                repeatDates.append(date)
            }
        }
        
        guard repeatDates.count > 0 else {
            return nil
        }
        
        return repeatDates
    }
    
    /// 判断特定日期是否为重复日
    private func isRepeatDate(_ date: Date, matching repeatRule: RepeatRule, startDate: Date, endDate: Date?) -> Bool {
        guard let type = repeatRule.type, type != .none else {
            return false
        }

        /// 判断是否结束
        if let endDate = endDate, endDate.isPreviousDay(of: date) {
            /// 结束日期在特定日期之前，非重复日
            return false
        }
    
        switch type {
        case .none:
            return false
        case .daily, .weekly, .weekday, .weekend, .monthly, .yearly:
            return isRegularlyRepeatDate(date, matching: repeatRule, startDate: startDate, repeatType: type)
        case .lunarYearly:
            return isLunarYearlyRepeatDate(date, matching: repeatRule, startDate: startDate)
        case .legalWorkday:
            return isLegalWorkdayRepeatDate(date, matching: repeatRule, startDate: startDate)
        case .ebbinghaus:
            return isEbbinghausRepeatDate(date, matching: repeatRule, startDate: startDate)
        case .custom:
            return isCustomRepeatDate(date, matching: repeatRule, startDate: startDate)
        }
    }
    
    func nextRepeatDate(completionDate: Date,
                                matching repeatRule: RepeatRule,
                                startDate: Date) -> Date? {
        var nextDate = nextRepeatDate(afterDate: completionDate, matching: repeatRule, startDate: startDate)
        if nextDate == nil,
            let type = repeatRule.type, type == .custom,
           let recurrenceRule = repeatRule.recurrenceRule,
           recurrenceRule.type == .afterCompletion {
            /// 处理结束后重复的情况
            let scheduler = RegularlyScheduler(firstWeekday: firstWeekday)
            nextDate = scheduler.nextRepeatDate(completionDate: completionDate, matching: recurrenceRule, startDate: startDate)
        }
       
        guard let nextDate = nextDate else {
            return nil
        }

        /// 比较结束日期
        if let endDate = endDate(of: repeatRule, startDate: startDate) {
            if endDate.isPreviousDay(of: nextDate) {
                /// 结束日期在特定日期之前，非重复日
                return nil
            }
        }
        
        return nextDate
    }
    
    private func repeatEndDate() -> Date? {
        return nil
    }
    
    private func nextRepeatDate(afterDate: Date,
                                matching repeatRule: RepeatRule,
                                startDate: Date) -> Date? {
        guard let type = repeatRule.type, type != .none else {
            return nil
        }
    
        var repeatDate: Date?
        switch type {
        case .none:
            repeatDate = nil
        case .daily, .weekly, .weekday, .weekend, .monthly, .yearly:
            repeatDate = nextRegularlyRepeatDate(afterDate: afterDate,
                                                 matching: repeatRule,
                                                 startDate: startDate,
                                                 repeatType: type)
        case .lunarYearly:
            repeatDate = nextLunarYearlyRepeatDate(afterDate: afterDate,
                                                   matching: repeatRule,
                                                   startDate: startDate)
        case .legalWorkday:
            repeatDate = nextLegalWorkdayRepeatDate(afterDate: afterDate,
                                                    matching: repeatRule,
                                                    startDate: startDate)
        case .ebbinghaus:
            repeatDate = nextEbbinghausRepeatDate(afterDate: afterDate,
                                                  matching: repeatRule,
                                                  startDate: startDate)
        case .custom:
            repeatDate = nextCustomRepeatDate(afterDate: afterDate,
                                              matching: repeatRule,
                                              startDate: startDate)
        }
        
        guard let repeatDate = repeatDate else {
            return nil
        }

        if let end = repeatRule.end, let endDate = end.endDate {
            if endDate.isPreviousDay(of: repeatDate) {
                /// 结束日期在重复日期之前，返回 nil
                return nil
            }
        }
        
        return repeatDate
    }
    
    /// 获取重复特定次后的日期
    private func repeatDate(using repeatRule: RepeatRule, startDate: Date, times: Int) -> Date {
        if times <= 1 {
            return startDate
        }
        
        var endDate = startDate
        for _ in 1..<times {
            if let repeatDate = nextRepeatDate(afterDate: endDate, matching: repeatRule, startDate: startDate) {
                endDate = repeatDate
            } else {
                break
            }
        }
        
        return endDate
    }
    
    /// 根据开始日期获取重复规则对应的结束日期
    private func endDate(of repeatRule: RepeatRule, startDate: Date) -> Date? {
        guard let end = repeatRule.end else {
            return nil
        }
        
        var endDate: Date
        if let date = end.endDate {
            endDate = date
        } else {
            let currentOccurenceCount = repeatRule.count ?? 0
            let totalOccurenceCount = end.occurrenceCount ?? 1
            let times = totalOccurenceCount - currentOccurenceCount
            endDate = repeatDate(using: repeatRule, startDate: startDate, times: times)
        }
        
        return endDate
    }
    
    /// 定期重复类型
    private func isRegularlyRepeatDate(_ date: Date, matching repeatRule: RepeatRule, startDate: Date, repeatType: RepeatType) -> Bool {
        guard let recurrenceRule = repeatType.recurrenceRule(for: startDate) else {
            return false
        }
        
        let scheduler = RegularlyScheduler(firstWeekday: firstWeekday)
        return scheduler.isRepeatDate(date, matching: recurrenceRule, startDate: startDate)
    }
    
    private func nextRegularlyRepeatDate(afterDate: Date, matching repeatRule: RepeatRule, startDate: Date, repeatType: RepeatType) -> Date? {
        guard let recurrenceRule = repeatType.recurrenceRule(for: startDate) else {
            return nil
        }
        
        let scheduler = RegularlyScheduler(firstWeekday: firstWeekday)
        return scheduler.nextRepeatDate(afterDate: afterDate, matching: recurrenceRule, startDate: startDate)
    }
    
    /// 农历按年重复
    private func isLunarYearlyRepeatDate(_ date: Date, matching repeatRule: RepeatRule, startDate: Date) -> Bool {
        let scheduler = LunarYearlyRepeatScheduler()
        return scheduler.isRepeatDate(date, startDate: startDate)
    }
    
    private func nextLunarYearlyRepeatDate(afterDate: Date, matching repeatRule: RepeatRule, startDate: Date) -> Date? {
        let scheduler = LunarYearlyRepeatScheduler()
        return scheduler.nextRepeatDate(afterDate: afterDate, startDate: startDate)
    }

    /// 法定工作日重复
    private func isLegalWorkdayRepeatDate(_ date: Date, matching repeatRule: RepeatRule, startDate: Date) -> Bool {
        let scheduler = LegalWorkdayRepeatScheduler()
        return scheduler.isRepeatDate(date, startDate: startDate)
    }
    
    private func nextLegalWorkdayRepeatDate(afterDate: Date, matching repeatRule: RepeatRule, startDate: Date) -> Date? {
        let scheduler = LegalWorkdayRepeatScheduler()
        return scheduler.nextRepeatDate(afterDate: afterDate, startDate: startDate)
    }
    
    /// 遗忘曲线重复
    private func isEbbinghausRepeatDate(_ date: Date, matching repeatRule: RepeatRule, startDate: Date) -> Bool {
        let scheduler = EbbinghausRepeatScheduler()
        return scheduler.isRepeatDate(date, matching: repeatRule, startDate: startDate)
    }
    
    private func nextEbbinghausRepeatDate(afterDate: Date, matching repeatRule: RepeatRule, startDate: Date) -> Date? {
        let scheduler = EbbinghausRepeatScheduler()
        return scheduler.nextRepeatDate(afterDate: afterDate, matching: repeatRule, startDate: startDate)
    }
    
    /// 自定义重复
    private func isCustomRepeatDate(_ date: Date, matching repeatRule: RepeatRule, startDate: Date) -> Bool {
        guard let recurrenceRule = repeatRule.recurrenceRule else {
            return false
        }
        
        let scheduler = RegularlyScheduler(firstWeekday: firstWeekday)
        return scheduler.isRepeatDate(date, matching: recurrenceRule, startDate: startDate)
    }
    
    private func nextCustomRepeatDate(afterDate: Date, matching repeatRule: RepeatRule, startDate: Date) -> Date? {
        guard let recurrenceRule = repeatRule.recurrenceRule else {
            return nil
        }
        
        let scheduler = RegularlyScheduler(firstWeekday: firstWeekday)
        return scheduler.nextRepeatDate(afterDate: afterDate, matching: recurrenceRule, startDate: startDate)
    }
}

/// 农历按年重复计划器
class LunarYearlyRepeatScheduler {
    
    func isRepeatDate(_ date: Date, startDate: Date) -> Bool {
        guard startDate.lunarYear <= date.lunarYear else {
            return false
        }
        
        if date.lunarMonth == startDate.lunarMonth, date.lunarDay == startDate.lunarDay {
            return true
        }
        
        return false
    }
    
    func nextRepeatDate(afterDate: Date, startDate: Date) -> Date? {
        if afterDate.isPreviousDay(of: startDate) {
            return startDate
        }
    
        let chineseCalendar = Calendar(identifier: .chinese)
        let startDateComponents = chineseCalendar.dateComponents([.year, .month, .day], from: startDate)
        guard let lunarMonth = startDateComponents.month,
              let lunarDay = startDateComponents.day else {
            return nil
        }
        
        // 从afterDate开始逐年查找，直到找到下一个匹配的农历日期
        var currentYear = chineseCalendar.component(.year, from: afterDate)
        while true {
            // 构建下一年的农历日期
            let nextLunarDateComponents = DateComponents(calendar: chineseCalendar,
                                                         year: currentYear,
                                                         month: lunarMonth,
                                                         day: lunarDay)
            if let nextDate = chineseCalendar.date(from: nextLunarDateComponents), nextDate.isFutureDay(of: afterDate) {
                return nextDate
            }
            
            // 如果没有找到合适的日期，则继续下一年
            currentYear += 1
        }
    }
}

/// 法定工作日重复计划器
class LegalWorkdayRepeatScheduler {
    
    func isRepeatDate(_ date: Date, startDate: Date) -> Bool {
        guard startDate.isPreviousDay(of: date) else {
            return false
        }
        
        return isLegalWorkday(of: date)
    }
    
    func nextRepeatDate(afterDate: Date, startDate: Date) -> Date? {
        var afterDate = afterDate
        if afterDate.isPreviousDay(of: startDate) {
            /// 日期设置为开始日的上一天
            afterDate = startDate.dateByAddingDays(-1)!
        }
    
        var result: Date?
        for days in 1...365 {
            if let date = afterDate.dateByAddingDays(days), isLegalWorkday(of: date) {
                result = date
                break
            }
        }
        
        return result
    }
    
    private func isLegalWorkday(of date: Date) -> Bool {
        let state = TPHolidayScheduler.shared.state(for: date)
        let weekday = Weekday(date: date)
        if weekday.isWeekend {
            /// 周末检查是否为调休工作日
            return state == .inWorking
        }
        
        /// 工作日判断是否为节假日
        return state != .onHoliday
    }
}

/// 遗忘曲线重复计划器
class EbbinghausRepeatScheduler {
    
    let intervals = [1, 2, 4, 7, 15, 30]
    
    func isRepeatDate(_ date: Date, matching repeatRule: RepeatRule, startDate: Date) -> Bool {
        guard startDate.isPreviousDay(of: date) else {
            return false
        }
        
        let repeatCount = repeatRule.count ?? 0
        let originStartDate = originStartDate(for: startDate, repeatCount: repeatCount)
        let daysCount = Date.days(fromDate: originStartDate, toDate: date)
        if daysCount > 30 {
            return daysCount % 15 == 0
        } else {
            return intervals.contains(daysCount)
        }
    }
    
    func nextRepeatDate(afterDate: Date, matching repeatRule: RepeatRule, startDate: Date) -> Date? {
        if afterDate.isPreviousDay(of: startDate) {
            return startDate
        }
        
        let repeatCount = repeatRule.count ?? 0
        let originStartDate = originStartDate(for: startDate, repeatCount: repeatCount)
        var nextInterval: Int?
        let daysCount = Date.days(fromDate: originStartDate, toDate: afterDate)
        if daysCount < 30 {
            for interval in intervals {
                if interval > daysCount {
                    nextInterval = interval
                    break
                }
            }
        } else {
            /// 天数间隔大于30天
            nextInterval = 30 + ((daysCount - 30) / 15 + 1) * 15
        }
        
        guard let nextInterval = nextInterval else {
            return nil
        }

        return originStartDate.dateByAddingDays(nextInterval)
    }
    
    /// 根据当前开始日期和当前重复数获取最初开始日
    private func originStartDate(for startDate: Date, repeatCount: Int) -> Date {
        guard repeatCount > 0 else {
            return startDate
        }

        /// 计算最初开始日期
        let index = repeatCount - 1
        let addingDays: Int
        if index < intervals.count {
            addingDays = intervals[index]
        } else {
            addingDays = 30 + (index - 5) * 15
        }
        
        return startDate.dateByAddingDays(-addingDays)!
    }
}

/// 定期重复计划器
class RegularlyScheduler {
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday
    
    init(firstWeekday: Weekday = .sunday) {
        self.firstWeekday = firstWeekday
    }
    
    func isRepeatDate(_ date: Date, matching recurrenceRule: RecurrenceRule, startDate: Date) -> Bool {
        let type = recurrenceRule.getType()
        switch type {
        case .regularly:
            return isRegularlyRepeatDate(date, matching: recurrenceRule, startDate: startDate)
        case .afterCompletion:
            return false
        case .specificDates:
            return isSpecificRepeatDate(date, matching: recurrenceRule, startDate: startDate)
        }
    }
    
    private func isRegularlyRepeatDate(_ date: Date, matching recurrenceRule: RecurrenceRule, startDate: Date) -> Bool {
        if date.isPreviousDay(of: startDate) {
            return false
        }
        
        let interval = recurrenceRule.getInterval()
        let frequency = recurrenceRule.getFrequency()
        switch frequency {
        case .daily:
            return isDailyRepeatDate(for: date, startDate: startDate, interval: interval)
        case .weekly:
            if let weekdays = recurrenceRule.daysOfTheWeek?.weekdays, weekdays.count > 0 {
                return isWeeklyRepeatDate(for: date,
                                            startDate: startDate,
                                            interval: interval,
                                            weekdays: weekdays,
                                            firstWeekday: firstWeekday)
            }
            
            return false
        case .monthly:
            if recurrenceRule.monthlyMode == .onDays {
                guard let daysOfTheMonth = recurrenceRule.daysOfTheMonth else {
                    return false
                }
                
                return isMonthlyRepeatDate(for: date,
                                             startDate: startDate,
                                             interval: interval,
                                             daysOfTheMonth: daysOfTheMonth)
            } else {
                guard let dayOfTheWeek = recurrenceRule.daysOfTheWeek?.first else {
                    return false
                }
                
                return isMonthlyRepeatDate(for: date,
                                             startDate: startDate,
                                             interval: interval,
                                             dayOfTheWeek: dayOfTheWeek)
            }
        case .yearly:
            guard let monthsOfTheYear = recurrenceRule.monthsOfTheYear, monthsOfTheYear.count > 0 else {
                return false
            }
            
            if recurrenceRule.monthlyMode == .onDays {
                guard let daysOfTheMonth = recurrenceRule.daysOfTheMonth else {
                    return false
                }
                
                return isYearlyRepeatDate(for: date,
                                            startDate: startDate,
                                            interval: interval,
                                            monthsOfTheYear: monthsOfTheYear,
                                            daysOfTheMonth: daysOfTheMonth)
            } else {
                guard let dayOfTheWeek = recurrenceRule.daysOfTheWeek?.first else {
                    return false
                }
                
                return isYearlyRepeatDate(for: date,
                                            startDate: startDate,
                                            interval: interval,
                                            monthsOfTheYear: monthsOfTheYear,
                                            dayOfTheWeek: dayOfTheWeek)
            }
        }
    }
    
    /// 是否为自定义重复日期
    private func isSpecificRepeatDate(_ date: Date, matching recurrenceRule: RecurrenceRule, startDate: Date) -> Bool {
        if date.isPreviousDay(of: startDate) {
            return false
        }
        
        guard let specificDates = recurrenceRule.specificDates else {
            return false
        }
        
        for specificDate in specificDates {
            if specificDate.isInSameDayAs(date) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - 按日
    // 检查一个特定日期是否为重复日
    private func isDailyRepeatDate(for date: Date, startDate: Date, interval: Int) -> Bool {
        if interval <= 0 || date.isPreviousDay(of: startDate) {
            return false
        }
        
        let daysDifference = Date.days(fromDate: startDate, toDate: date)
        return daysDifference % interval == 0
    }
    
    // MARK: - 按周
    private func isWeeklyRepeatDate(for date: Date,
                                   startDate: Date,
                                   interval: Int,
                                   weekdays: [Weekday],
                                   firstWeekday: Weekday = .sunday) -> Bool {
        guard interval > 0, weekdays.count > 0 else {
            return false
        }
        
        if date.isPreviousDay(of: startDate) {
            /// 当前日期在开始日期之前
            return false
        }
        
        let weeksDifference = Date.weeks(fromDate: startDate, toDate: date)
        if weeksDifference % interval != 0 {
            /// 非计划周
            return false
        }
        
        let weekday = Weekday(date: date)
        if weekdays.contains(weekday) {
            return true
        }
        
        return false
    }

    // MARK: - 按月
    /// 月按天
    private func isMonthlyRepeatDate(for date: Date,
                                    startDate: Date,
                                    interval: Int,
                                    daysOfTheMonth: [Int]) -> Bool {
        guard isMonthlyRepeatMonth(for: date, startDate: startDate, interval: interval) else {
            return false
        }
        
        if daysOfTheMonth.contains(date.day) {
            return true
        }
        
        /// 判断最后一天
        /// 包含最后一天索引并且date是当月最后一天
        if daysOfTheMonth.contains(-1) && date.isLastDayOfMonth {
            return true
        }
        
        return false
    }
    
    /// 月按周
    private func isMonthlyRepeatDate(for date: Date,
                                    startDate: Date,
                                    interval: Int,
                                    dayOfTheWeek: RepeatDayOfWeek) -> Bool {
        guard !date.isPreviousDay(of: startDate),
              isMonthlyRepeatMonth(for: date, startDate: startDate, interval: interval) else {
            return false
        }
        
        if let repeatDate = Date.dateForRepeatDayOfWeek(dayOfTheWeek, inMonthOf: date) {
            return repeatDate.isInSameDayAs(date)
        }
        
        return false
    }
    
    /// 是否是重复月
    private func isMonthlyRepeatMonth(for date: Date, startDate: Date, interval: Int) -> Bool {
        guard interval > 0 else {
            return false
        }
        
        let monthsDifference = Date.months(fromDate: startDate, toDate: date)
        if monthsDifference < 0 {
            return false
        }
        
        if monthsDifference % interval != 0 {
            /// 非计划月
            return false
        }
        
        return true
    }
    
    // MARK: - 按年
    
    /// 年重复按天
    private func isYearlyRepeatDate(for date: Date,
                                   startDate: Date,
                                   interval: Int,
                                   monthsOfTheYear: [Int],
                                   daysOfTheMonth: [Int]) -> Bool {
        guard !date.isPreviousDay(of: startDate),
              isYearlyRepeatYear(for: date, startDate: startDate, interval: interval),
              monthsOfTheYear.contains(date.month) else {
            return false
        }
        
        if daysOfTheMonth.contains(date.day) {
            return true
        }
        
        /// 判断最后一天
        if daysOfTheMonth.contains(-1) && date.isLastDayOfMonth {
            return true
        }

        return false
    }
    
    /// 年重复按周
    private func isYearlyRepeatDate(for date: Date,
                                   startDate: Date,
                                   interval: Int,
                                   monthsOfTheYear: [Int],
                                   dayOfTheWeek: RepeatDayOfWeek) -> Bool {
        guard !date.isPreviousDay(of: startDate),
              isYearlyRepeatYear(for: date, startDate: startDate, interval: interval),
              monthsOfTheYear.contains(date.month) else {
            return false
        }

        if let repeatDate = Date.dateForRepeatDayOfWeek(dayOfTheWeek, inMonthOf: date) {
            return repeatDate.isInSameDayAs(date)
        }

        return false
    }
    
    /// 是否是按年重复的计划年
    private func isYearlyRepeatYear(for date: Date, startDate: Date, interval: Int) -> Bool {
        guard interval > 0 else {
            return false
        }
        
        if date.year < startDate.year {
            /// 当前日期年在开始日期年之前
            return false
        }
        
        let yearsDifference = Date.years(fromDate: startDate, toDate: date)
        if yearsDifference % interval != 0 {
            /// 非计划年
            return false
        }
        
        return true
    }
}

/// 获取特定日期下一个重复日
extension RegularlyScheduler {
    
    /// 获取在完成日期之后的下一个重复日
    func nextRepeatDate(completionDate: Date, matching recurrenceRule: RecurrenceRule, startDate: Date) -> Date? {
        let type = recurrenceRule.getType()
        switch type {
        case .regularly:
            return nextRegularlyRepeatDate(afterDate: completionDate, matching: recurrenceRule, startDate: startDate)
        case .afterCompletion:
            return nextRepeatDateAfterCompletion(completionDate, matching: recurrenceRule)
        case .specificDates:
            return nextSpecificRepeatDate(afterDate: completionDate, matching: recurrenceRule, startDate: startDate)
        }
    }
    
    /// 获取在特定日期之后的下一个重复日
    func nextRepeatDate(afterDate: Date, matching recurrenceRule: RecurrenceRule, startDate: Date) -> Date? {
        let type = recurrenceRule.getType()
        switch type {
        case .regularly:
            return nextRegularlyRepeatDate(afterDate: afterDate, matching: recurrenceRule, startDate: startDate)
        case .afterCompletion:
            return nil
        case .specificDates:
            return nextSpecificRepeatDate(afterDate: afterDate, matching: recurrenceRule, startDate: startDate)
        }
    }
    
    /// 获取完成任务后的下一个重复日期
    private func nextRepeatDateAfterCompletion(_ completionDate: Date, matching recurrenceRule: RecurrenceRule) -> Date? {
        guard recurrenceRule.type == .afterCompletion else {
            return nil
        }
        
        let interval = recurrenceRule.getInterval()
        let frequency = recurrenceRule.getFrequency()
        switch frequency {
        case .daily:
            return completionDate.dateByAddingDays(interval)
        case .weekly:
            return completionDate.dateByAddingWeeks(interval)
        case .monthly:
            return completionDate.dateByAddingMonths(interval)
        case .yearly:
            return completionDate.dateByAddingYears(interval)
        }
    }
    
    private func nextSpecificRepeatDate(afterDate: Date, matching recurrenceRule: RecurrenceRule, startDate: Date) -> Date? {
        guard let specificDates = recurrenceRule.specificDates?.sorted(), specificDates.count > 0 else {
            return nil
        }
        
        for specificDate in specificDates {
            if specificDate.isFutureDay(of: afterDate), specificDate.isFutureOrSameDay(as: startDate) {
                return specificDate
            }
        }
        
        return nil
    }
    
    private func nextRegularlyRepeatDate(afterDate: Date, matching recurrenceRule: RecurrenceRule, startDate: Date) -> Date? {
        let interval = recurrenceRule.getInterval()
        let frequency = recurrenceRule.getFrequency()
        switch frequency {
        case .daily:
            return nextDailyRepeatDate(afterDate: afterDate, startDate: startDate, interval: interval)
        case .weekly:
            return nextWeeklyRepeatDate(afterDate: afterDate,
                                        startDate: startDate,
                                        interval: interval,
                                        daysOfTheWeek: recurrenceRule.daysOfTheWeek,
                                        firstWeekday: firstWeekday)
        case .monthly:
            return nextMonthlyRepeatDate(afterDate: afterDate, matching: recurrenceRule, startDate: startDate)
        case .yearly:
            return nextYearlyRepeatDate(afterDate: afterDate, matching: recurrenceRule, startDate: startDate)
        }
    }
    
    // MARK: - 按天
    private func nextDailyRepeatDate(afterDate: Date,
                             startDate: Date,
                             interval: Int) -> Date? {
        guard interval > 0 else {
            return nil
        }
        
        let daysDifference = Date.days(fromDate: startDate, toDate: afterDate)
        guard daysDifference >= 0 else {
            return startDate
        }
        
        let nextRepetitionIndex = (daysDifference / interval) + 1
        let daysToAdd = nextRepetitionIndex * interval - daysDifference
        return afterDate.dateByAddingDays(daysToAdd)
    }
    
    // MARK: - 按周
    private func nextWeeklyRepeatDate(afterDate: Date,
                                      startDate: Date,
                                      interval: Int,
                                      daysOfTheWeek: [RepeatDayOfWeek]?,
                                      firstWeekday: Weekday = .sunday) -> Date? {
        guard interval > 0, let weekdays = daysOfTheWeek?.weekdays, weekdays.count > 0 else {
            return nil
        }

        var weeksDifference = Date.weeks(fromDate: startDate, toDate: afterDate, firstWeekday: firstWeekday)
        if weeksDifference < 0 {
            weeksDifference = 0
        }
        
        var closestRepeatWeek = closestInterval(with: weeksDifference, interval: interval)
        while true {
            let weekDate = startDate.dateByAddingWeeks(closestRepeatWeek)!
            let weekStartDate = weekDate.firstDayOfWeek(firstWeekday: firstWeekday)
            for day in 0..<DAYS_PER_WEEK {
                let date = weekStartDate.dateByAddingDays(day)!
                let weekday = Weekday(date: date)
                if weekdays.contains(weekday),
                   date.isFutureOrSameDay(as: startDate),
                   date.isFutureDay(of: afterDate) {
                    return date
                }
            }
            
            // 如果没有找到合适的日期，则继续下一个计划周
            closestRepeatWeek += interval
        }
    }

    // MARK: - 按月
    private func nextMonthlyRepeatDate(afterDate: Date, matching recurrenceRule: RecurrenceRule, startDate: Date) -> Date? {
        let interval = recurrenceRule.getInterval()
        if recurrenceRule.monthlyMode == .onDays {
            guard let daysOfTheMonth = recurrenceRule.daysOfTheMonth else {
                return nil
            }
            
            return nextMonthlyRepeatDate(afterDate: afterDate,
                                         startDate: startDate,
                                         interval: interval,
                                         daysOfTheMonth: daysOfTheMonth)
        } else {
            guard let dayOfTheWeek = recurrenceRule.daysOfTheWeek?.first else {
                return nil
            }
            
            return nextMonthlyRepeatDate(afterDate: afterDate,
                                         startDate: startDate,
                                         interval: interval,
                                         dayOfTheWeek: dayOfTheWeek)
        }
    }
    
    /// 按月搜索最大搜索次数
    private static let maximumMonthlyNextDateSearchCount = 120
    
    /// 月按天
    private func nextMonthlyRepeatDate(afterDate: Date,
                                       startDate: Date,
                                       interval: Int,
                                       daysOfTheMonth: [Int]) -> Date? {
        guard interval > 0, daysOfTheMonth.count > 0 else {
            return nil
        }
        
        var closestRepeatMonth = closestRepeatMonth(afterDate: afterDate,
                                                    startDate: startDate,
                                                    interval: interval)
        let startMonthFirstDate = startDate.firstDayOfMonth()
        for _ in 0...Self.maximumMonthlyNextDateSearchCount {
            let monthStartDate = startMonthFirstDate.dateByAddingMonths(closestRepeatMonth)!
            let monthDaysCount = monthStartDate.numberOfDaysInMonth()
            for day in 0..<monthDaysCount {
                let date = monthStartDate.dateByAddingDays(day)!
                guard daysOfTheMonth.contains(date.day) || (daysOfTheMonth.contains(-1) && date.isLastDayOfMonth) else {
                    continue
                }
                
                if date.isFutureOrSameDay(as: startDate), date.isFutureDay(of: afterDate) {
                    return date
                }
            }
            
            // 如果没有找到合适的日期，则继续下一个计划月
            closestRepeatMonth += interval
        }
        
        return nil
    }
    
    /// 月按周
    private func nextMonthlyRepeatDate(afterDate: Date,
                               startDate: Date,
                               interval: Int,
                               dayOfTheWeek: RepeatDayOfWeek) -> Date? {
        guard interval > 0 else {
            return nil
        }
        
        var closestRepeatMonth = closestRepeatMonth(afterDate: afterDate,
                                                    startDate: startDate,
                                                    interval: interval)
        let startMonthFirstDate = startDate.firstDayOfMonth()
        for _ in 0...Self.maximumMonthlyNextDateSearchCount {
            let monthStartDate = startMonthFirstDate.dateByAddingMonths(closestRepeatMonth)!
            if let nextDate = Date.dateForRepeatDayOfWeek(dayOfTheWeek, inMonthOf: monthStartDate) {
                if nextDate.isFutureOrSameDay(as: startDate), nextDate.isFutureDay(of: afterDate) {
                    return nextDate
                }
            }
            
            // 如果没有找到合适的日期，则继续下一个计划月
            closestRepeatMonth += interval
        }
        
        return nil
    }
    
    /// 获取与 afterDate 最相近的重复月与开始日期所在月之间的月数间隔
    private func closestRepeatMonth(afterDate: Date,
                                    startDate: Date,
                                    interval: Int) -> Int {
        var monthsDifference = Date.months(fromDate: startDate, toDate: afterDate)
        if monthsDifference < 0 {
            monthsDifference = 0
        }
    
        return closestInterval(with: monthsDifference, interval: interval)
    }
    
    // MARK: - 按年
    private func nextYearlyRepeatDate(afterDate: Date, matching recurrenceRule: RecurrenceRule, startDate: Date) -> Date? {
        guard let monthsOfTheYear = recurrenceRule.monthsOfTheYear, monthsOfTheYear.count > 0 else {
            return nil
        }
        
        let interval = recurrenceRule.getInterval()
        if recurrenceRule.monthlyMode == .onDays {
            guard let daysOfTheMonth = recurrenceRule.daysOfTheMonth else {
                return nil
            }
            
            return nextYearlyRepeatDate(afterDate: afterDate,
                                        startDate: startDate,
                                        interval: interval,
                                        monthsOfTheYear: monthsOfTheYear,
                                        daysOfTheMonth: daysOfTheMonth)
        } else {
            guard let dayOfTheWeek = recurrenceRule.daysOfTheWeek?.first else {
                return nil
            }
            
            return nextYearlyRepeatDate(afterDate: afterDate,
                                        startDate: startDate,
                                        interval: interval,
                                        monthsOfTheYear: monthsOfTheYear,
                                        dayOfTheWeek: dayOfTheWeek)
        }
    }

    /// 年重复按天
    private func nextYearlyRepeatDate(afterDate: Date,
                                      startDate: Date,
                                      interval: Int,
                                      monthsOfTheYear: [Int],
                                      daysOfTheMonth: [Int]) -> Date? {
        guard interval > 0, monthsOfTheYear.count > 0, daysOfTheMonth.count > 0 else {
            return nil
        }
        
        var closestRepeatYear = closestRepeatYear(afterDate: afterDate,
                                                    startDate: startDate,
                                                    interval: interval)
        let startYearFirstDay = startDate.firstDayOfYear()
        for _ in 0...12 {
            let yearStartDate = startYearFirstDay.dateByAddingYears(closestRepeatYear)!
            /// 遍历月
            for addingMonth in 0..<MONTHS_PER_YEAR {
                let month = addingMonth + 1
                if !monthsOfTheYear.contains(month) {
                    continue
                }
                
                let monthStartDate = yearStartDate.dateByAddingMonths(addingMonth)!
                if monthStartDate.isBeforeMonth(of: startDate) || monthStartDate.isBeforeMonth(of: afterDate) {
                    /// 当前月在开始日或特定日之前的月份，跳出当前月比较
                    continue
                }
                
                let monthDaysCount = monthStartDate.numberOfDaysInMonth()
                for day in 0..<monthDaysCount {
                    let date = monthStartDate.dateByAddingDays(day)!
                    guard daysOfTheMonth.contains(date.day) || (daysOfTheMonth.contains(-1) && date.isLastDayOfMonth) else {
                        continue
                    }
                    
                    if date.isFutureOrSameDay(as: startDate), date.isFutureDay(of: afterDate) {
                        return date
                    }
                }
            }
            
            closestRepeatYear += interval
        }
        
        return nil
    }
    
    /// 年重复按周
    private func nextYearlyRepeatDate(afterDate: Date,
                                      startDate: Date,
                                      interval: Int,
                                      monthsOfTheYear: [Int],
                                      dayOfTheWeek: RepeatDayOfWeek) -> Date? {
        guard interval > 0, monthsOfTheYear.count > 0 else {
            return nil
        }
        
        var closestRepeatYear = closestRepeatYear(afterDate: afterDate,
                                                    startDate: startDate,
                                                    interval: interval)
        let startYearFirstDay = startDate.firstDayOfYear()
        for _ in 0...12 {
            let yearStartDate = startYearFirstDay.dateByAddingYears(closestRepeatYear)!
            for addingMonth in 0..<MONTHS_PER_YEAR {
                let month = addingMonth + 1
                if !monthsOfTheYear.contains(month) {
                    continue
                }
                
                let monthStartDate = yearStartDate.dateByAddingMonths(addingMonth)!
                if monthStartDate.isBeforeMonth(of: startDate) || monthStartDate.isBeforeMonth(of: afterDate) {
                    /// 当前月在开始日或特定日之前的月份，跳出当前月比较
                    continue
                }
                
                if let nextDate = Date.dateForRepeatDayOfWeek(dayOfTheWeek, inMonthOf: monthStartDate),
                   nextDate.isFutureOrSameDay(as: startDate),
                   nextDate.isFutureDay(of: afterDate) {
                        return nextDate
                }
            }
            
            closestRepeatYear += interval
        }
        
        return nil
    }
    
    /// 获取与 afterDate 最相近的重复年与开始日期所在年之间的年数目间隔
    private func closestRepeatYear(afterDate: Date,
                                   startDate: Date,
                                   interval: Int) -> Int {
        var yearsDifference = Date.years(fromDate: startDate, toDate: afterDate)
        if yearsDifference < 0 {
            yearsDifference = 0
        }
        
        return closestInterval(with: yearsDifference, interval: interval)
    }

    // MARK: - Helpers
    private func closestInterval(with difference: Int, interval: Int) -> Int {
        var closestInterval: Int
        if difference % interval == 0 {
            closestInterval = difference
        } else {
            closestInterval = difference + (interval - difference % interval)
        }
        
        return closestInterval
    }
    
}

//
//  TodoDateFilterValue.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/2.
//

import Foundation

/// 日期过滤值
struct TodoDateFilterValue: Hashable, Codable, PredicateProvider {
    
    enum RangeType: Int, Codable, TPMenuRepresentable {
        case specific
        case relative
        
        var title: String {
            switch self {
            case .specific:
                return resGetString("Specific")
            case .relative:
                return resGetString("Relative")
            }
        }
    }
    
    /// 范围类型
    var rangeType: RangeType? = .specific
 
    /// 指定日期范围
    var specificDateRange: TodoSpecificDateRange?
    
    /// 相对日期范围
    var relativeDateRange: TodoRelativeDateRange?

    var description: String? {
        let rangeType = getRangeType()
        if rangeType == .specific {
            return specificDateRange?.description
        } else {
            return relativeDateRange?.description
        }
    }
    
    func getRangeType() -> RangeType {
        return rangeType ?? .specific
    }
    
    /// 获取具体的日期范围
    func dateRange(firstWeekday: Weekday = .firstWeekday) -> DateRange? {
        switch getRangeType() {
        case .specific:
            return specificDateRange?.dateRange
        case .relative:
            return relativeDateRange?.dateRange(firstWeekday: firstWeekday)
        }
    }
    
    func suitableStartDate() -> Date? {
        guard let dateRange = dateRange() else {
            return nil
        }
        
        return TodoDateFilterValue.suitableStartDate(for: dateRange)
    }

    var predicate: NSPredicate? {
        guard let dateRange = dateRange(firstWeekday: .firstWeekday),
                let startDate = dateRange.startDate,
                let endDate = dateRange.endDate else {
            return nil
        }
    
        let condition: PredicateCondition = (TodoTaskKey.startDate, .between(startDate, endDate))
        return NSPredicate.predicate(with: condition)
    }
    
    /// 返回符合过滤日期范围的任务开始日期
    static func suitableStartDate(for dateRange: DateRange) -> Date? {
        guard let startDate = dateRange.startDate, let endDate = dateRange.endDate, startDate <= endDate else {
            return nil
        }

        let now = Date()
        // 检查当前时间是否在范围内
        if now >= startDate && now <= endDate {
            // 当前时间在范围内，直接返回当前时间作为开始日期
            return now
        } else if now < startDate {
            // 当前时间早于起始日期，返回起始日期
            return startDate
        } else {
            // 当前时间晚于结束日期，返回结束日期（或根据需求选择起始日期）
            return endDate // 或返回 startDate
        }
    }
    
}

/// 指定日期范围
struct TodoSpecificDateRange: Hashable, Codable {
    
    var fromDate: Date?
    
    var toDate: Date?
    
    var isValid: Bool {
        guard let fromDate = fromDate, let toDate = toDate else {
            return false
        }
        
        return fromDate <= toDate
    }
    
    var dateRange: DateRange? {
        if isValid {
            return DateRange(startDate: fromDate, endDate: toDate)
        }
        
        return nil
    }
    
    var description: String? {
        guard let fromDate = fromDate, let toDate = toDate else {
            return nil
        }
        
        let fromDateString = fromDate.yearMonthDayString(omitYear: true, showRelativeDate: false)
        let toDateString = toDate.yearMonthDayString(omitYear: true, showRelativeDate: false)
        let format = resGetString("Between %@ and %@")
        return String(format: format, fromDateString, toDateString)
    }
    
    init() {
        self.resetDate()
    }
    
    mutating func resetDate() {
        self.fromDate = .now.startOfDay()
        self.toDate = .now.endOfDay()
    }
    
    /// 当前编辑类型对应的日期
    func date(for rangeType: DateRangeEditType) -> Date? {
        return rangeType == .start ? fromDate : toDate
    }
    
    mutating func setDate(_ date: Date?, for rangeType: DateRangeEditType) {
        if rangeType == .start {
            self.fromDate = date
            if let date = date, let toDate = toDate, date > toDate {
                /// 开始日期大于结束日期，结束日期置为开始日的结束日期
                self.toDate = date.endOfDay()
            }
        } else {
            self.toDate = date
            if let date = date, let fromDate = fromDate, date < fromDate {
                /// 开始日期大于结束日期，开始日期置为结束日的开始日期
                self.fromDate = date.startOfDay()
            }
        }
    }
    
    // MARK: - 日期格式化字符串
    func fromDateText() -> String? {
        return fromDate?.yearMonthDayTimeString(omitYear: true)
    }

    func toDateText() -> String? {
        return toDate?.yearMonthDayTimeString(omitYear: true)
    }
}

struct TodoRelativeDateRange: Hashable, Codable {
    
    /// 锚点日期
    var anchorDate: TodoRelativeAnchorDate?

    /// 偏移
    var offset: TodoRelativeDateOffset?
    
    /// 描述文本
    var description: String? {
        var values: [String] = []
        
        let anchorDate = anchorDate ?? TodoRelativeAnchorDate()
        if let dateDescription = anchorDate.description {
            values.append(dateDescription)
        }
        
        let offset = offset ?? TodoRelativeDateOffset()
        if let offsetDescription = offset.description {
            values.append(offsetDescription)
        }
        
        guard values.count > 0 else {
            return nil
        }
        
        return values.joined(separator: " → ")
    }
    
    func dateRange(firstWeekday: Weekday = .firstWeekday) -> DateRange? {
        let anchorDate = anchorDate ?? TodoRelativeAnchorDate()
        let offset = offset ?? TodoRelativeDateOffset()
        return offset.dateRange(forDate: anchorDate.date, firstWeekday: firstWeekday)
    }
}

/// 锚点日期
struct TodoRelativeAnchorDate: Hashable, Codable {
    
    /// 日期类型
    enum DateType: Int, Hashable, Codable, TPMenuRepresentable {
        case today = 0        // 今天
        case weekStart        // 本周开始日（根据应用设置的周起始日，如周日或周一）
        case monthStart       // 本月1号零点
        case yearStart        // 本年1月1日零点
        
        var title: String {
            switch self {
            case .today:
                return resGetString("Today")
            case .weekStart:
                return resGetString("Week Start")
            case .monthStart:
                return resGetString("Month Start")
            case .yearStart:
                return resGetString("Year Start")
            }
        }
    }
    
    /// 日期类型
    var dateType: DateType?
    
    /// 时间偏移
    var offset: TimeOffset?
    
    /// 获取当前日期对应的锚点日期
    var date: Date {
        guard let offset = offset else {
            return .now
        }

        var amount = offset.getAmount()
        if amount == 0 {
            return .now
        }
        
        amount = Int(abs(amount))
        let direction = offset.getDirection()
        if direction == .before {
            amount = -amount
        }
    
        var result: Date?
        let unit = offset.getUnit()
        switch unit {
        case .hour:
            result = .now.dateByAddingHours(amount)
        case .day:
            result = .now.dateByAddingDays(amount)
        case .week:
            result = .now.dateByAddingWeeks(amount)
        case .month:
            result = .now.dateByAddingMonths(amount)
        case .year:
            result = .now.dateByAddingYears(amount)
        }
        
        return result ?? .now
    }
    
    /// 返回锚点日期描述标题
    var description: String? {
        guard let offset = offset, let amount = offset.amount, amount != 0 else {
            return resGetString("Today")
        }

        return offset.title
    }
}

struct TodoRelativeDateOffset: Hashable, Codable {
    
    enum Direction: Int, Hashable, Codable, TPMenuRepresentable {
        case next = 0
        case previous
        case current
        
        var title: String {
            switch self {
            case .current:
                return resGetString("In the Current")
            case .next:
                return resGetString("In the Next")
            case .previous:
                return resGetString("In the Previous")
            }
        }
    }

    static var minimumAmount = 1
    static var maximumAmount = 999
    static var permittedUnits: [TimeUnit] = [.day, .week, .month, .year]
    
    // 时间方向
    var direction: Direction? = .next
    
    // 时间单位数量
    var amount: Int? = 1
    
    // 时间单位
    var unit: TimeUnit? = .day

    /// 描述文本
    var description: String? {
        let format: String
        let direction = getDirection()
        switch direction {
        case .current:
            format = resGetString("In the Current %@")
        case .next:
            format = resGetString("In the Next %@")
        case .previous:
            format = resGetString("In the Previous %@")
        }
    
        let amount = getAmount()
        let timeUnit = getTimeUnit().localizedUnit(for: amount)
        let countStr = String(format: resGetString("%ld %@"), amount, timeUnit)
        return String(format: format, countStr)
    }
    
    func getAmount() -> Int {
        var value = amount ?? Self.minimumAmount
        clampValue(&value, Self.minimumAmount, Self.maximumAmount)
        return value
    }
    
    func getTimeUnit() -> TimeUnit {
        return unit ?? .day
    }
    
    func getDirection() -> Direction {
        return direction ?? .next
    }
    
    func dateRange(forDate date: Date, firstWeekday: Weekday = .firstWeekday) -> DateRange? {
        let amount = getAmount()
        let unit = getTimeUnit()
        let direction = getDirection()
        switch direction {
        case .current:
            return currentDateRange(forDate: date, unit: unit, firstWeekday: firstWeekday)
        case .next:
            return nextDateRange(forDate: date, amount: amount, unit: unit, firstWeekday: firstWeekday)
        case .previous:
            return previousDateRange(forDate: date, amount: amount, unit: unit, firstWeekday: firstWeekday)
        }
    }
    
    private func currentDateRange(forDate date: Date, unit: TimeUnit, firstWeekday: Weekday) -> DateRange? {
        let dateRange: (startDate: Date?, endDate: Date?)
        switch unit {
        case .hour:
            dateRange = (date.startOfHour(), date.endOfHour())
        case .day:
            dateRange = (date.startOfDay(), date.endOfDay())
        case .week:
            dateRange = (date.startOfWeek(firstWeekday: firstWeekday), date.endOfWeek(firstWeekday: firstWeekday))
        case .month:
            dateRange = (date.startOfMonth(), date.endOfMonth())
        case .year:
            dateRange = (date.startOfYear(), date.endOfYear())
        }
        
        return DateRange(startDate: dateRange.startDate, endDate: dateRange.endDate)
    }
    
    private func nextDateRange(forDate date: Date, amount: Int, unit: TimeUnit, firstWeekday: Weekday) -> DateRange? {
        var startDate: Date?
        var endDate: Date?
        switch unit {
        case .hour:
            startDate = date.endOfHour().dateByAddingSeconds(1)
            endDate = date.dateByAddingHours(amount)?.endOfHour()
        case .day:
            startDate = date.endOfDay().dateByAddingSeconds(1)
            endDate = date.dateByAddingDays(amount)?.endOfDay()
        case .week:
            startDate = date.endOfWeek(firstWeekday: firstWeekday).dateByAddingSeconds(1)
            endDate = date.dateByAddingWeeks(amount)?.endOfWeek(firstWeekday: firstWeekday)
        case .month:
            startDate = date.endOfMonth().dateByAddingSeconds(1)
            endDate = date.dateByAddingMonths(amount)?.endOfMonth()
        case .year:
            startDate = date.endOfYear().dateByAddingSeconds(1)
            endDate = date.dateByAddingYears(amount)?.endOfYear()
        }
        
        guard let startDate = startDate, let endDate = endDate, startDate <= endDate else {
            return nil
        }

        return DateRange(startDate: startDate, endDate: endDate)
    }
    
    private func previousDateRange(forDate date: Date, amount: Int, unit: TimeUnit, firstWeekday: Weekday) -> DateRange? {
        var startDate: Date?
        var endDate: Date?
        switch unit {
        case .hour:
            startDate = date.dateByAddingHours(-amount)?.startOfHour()
            endDate = date.startOfHour().dateByAddingSeconds(-1)
        case .day:
            startDate = date.dateByAddingDays(-amount)?.startOfDay()
            endDate = date.startOfDay().dateByAddingSeconds(-1)
        case .week:
            startDate = date.dateByAddingWeeks(-amount)?.startOfWeek(firstWeekday: firstWeekday)
            endDate = date.startOfWeek(firstWeekday: firstWeekday).dateByAddingSeconds(-1)
        case .month:
            startDate = date.dateByAddingMonths(-amount)?.startOfMonth()
            endDate = date.startOfMonth().dateByAddingSeconds(-1)
        case .year:
            startDate = date.dateByAddingYears(-amount)?.startOfYear()
            endDate = date.startOfYear().dateByAddingSeconds(-1)
        }
        
        guard let startDate = startDate, let endDate = endDate, startDate <= endDate else {
            return nil
        }
        
        return DateRange(startDate: startDate, endDate: endDate)
    }
}

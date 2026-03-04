//
//  StatisticPeriod.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/23.
//

import Foundation

class DatePeriod: NSObject {
    
    enum Mode: Int {
        case day
        case week
        case month
    }
    
    /// 时段模式
    let mode: Mode
    
    /// 日期
    let date: Date
    
    /// 日期对应模式表示的时间范围
    let dateRange: DateRange
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(mode)
        hasher.combine(dateRange)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DatePeriod else { return false }
        if self === other { return true }
        return mode == other.mode && dateRange == other.dateRange
    }
    
    /// 周模式周期
    convenience init(weekDate: Date, firstWeekday: Weekday = .firstWeekday) {
        self.init(date: weekDate, mode: .week, firstWeekday: firstWeekday)
    }
    
    init(date: Date, mode: Mode, firstWeekday: Weekday = .firstWeekday) {
        self.date = date
        self.mode = mode
        switch mode {
        case .day:
            dateRange = date.rangeOfThisDay()
        case .week:
            dateRange = date.rangeOfThisWeek(firstWeekday: firstWeekday)
        case .month:
            dateRange = date.rangeOfThisMonth()
        }
    }
    
    func contains(date: Date) -> Bool {
        return dateRange.contains(date: date)
    }
    
    /// 判断两个时段是否有交集
    func intersects(with otherPeriod: DatePeriod) -> Bool {
        let intersects = dateRange.intersects(with: otherPeriod.dateRange)
        return intersects
    }
    
    /// 是否是未来时段
    var isFuture: Bool {
        if let startDate = dateRange.startDate {
            return startDate.isFutureDay
        }
        
        return false
    }
    
}

class DatePeriodsProvider {
    
    /// 获取日期所在周的日时段数组
    static func weekPeriods(containDate date: Date = .now,
                            firstWeekday: Weekday = .firstWeekday) -> [DatePeriod] {
        var periods: [DatePeriod] = []
        let dates = date.thisWeekDays(firstWeekday: firstWeekday.rawValue)
        for date in dates {
            let period = DatePeriod(date: date, mode: .day)
            periods.append(period)
        }
        
        return periods
    }
}

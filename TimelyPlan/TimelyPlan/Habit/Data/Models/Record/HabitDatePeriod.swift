//
//  HabitDatePeriod.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation

class HabitDatePeriod: NSObject {
    
    enum Mode: Int {
        case day
        case week
        case month
        case year
    }
    
    /// 时段模式
    let mode: Mode
    
    /// 基准日期 (例如：周模式下的某一天，月模式下的某一天)
    let date: Date
    
    /// 日期对应模式表示的时间范围
    let dateRange: DateRange
    
    // MARK: - 初始化
    let firstWeekday: Weekday
    
    /// 通用初始化
    init(date: Date, mode: Mode, firstWeekday: Weekday = .firstWeekday) {
        self.date = date
        self.mode = mode
        self.firstWeekday = firstWeekday
        switch mode {
        case .day:
            self.dateRange = date.rangeOfThisDay()
        case .week:
            self.dateRange = date.rangeOfThisWeek(firstWeekday: firstWeekday)
        case .month:
            self.dateRange = date.rangeOfThisMonth()
        case .year:
            self.dateRange = date.rangeOfThisYear()
        }
    }
    
    /// 周模式周期快捷初始化
    static func weekPeriod(date: Date, firstWeekday: Weekday = .firstWeekday) -> HabitDatePeriod {
        return HabitDatePeriod(date: date, mode: .week, firstWeekday: firstWeekday)
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(mode)
        hasher.combine(dateRange)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? HabitDatePeriod else { return false }
        if self === other { return true }
        return mode == other.mode && dateRange == other.dateRange
    }
    
    
    /// 遍历时段内的所有日期
    /// - Parameter body: 对每个日期执行的闭包
    /// - Returns: 如果遍历完成返回 true，如果被中断返回 false
    @discardableResult
    func enumerateDates(using body: (Date) -> Bool) -> Bool {
        guard let startDate = dateRange.startDate,
              let endDate = dateRange.endDate else {
            return true
        }
        
        var currentDate = startDate
        let calendar = Calendar.current
        while currentDate <= endDate {
            let shouldContinue = body(currentDate)
            if !shouldContinue {
                return false
            }
            
            // 增加一天
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return true
    }

    // MARK: - 功能方法
    
    /// 判断指定日期是否在当前时段内
    func contains(_ date: Date) -> Bool {
        return dateRange.contains(date: date)
    }
    
    /// 判断两个时段是否有交集
    func intersects(_ period: HabitDatePeriod) -> Bool {
        return dateRange.intersects(with: period.dateRange)
    }
    
    func intersects(_ dateRange: DateRange) -> Bool {
        return self.dateRange.intersects(with: dateRange)
    }
    
    /// 是否是未来时段
    var isFuture: Bool {
        guard let startDate = dateRange.startDate else { return false }
        return startDate.isFutureDay
    }
    
    /// 当前时间范围已过去的天数
    var pastDaysCount: Int {
        if isFuture {
            return 0
        }
        
        var dateRange = self.dateRange
        let isFutureEndDate = dateRange.endDate?.isFutureDay ?? true
        if isFutureEndDate {
            dateRange.endDate = .now
        }
        
        return dateRange.lastsCount()
    }
    
    // MARK: - 获取日期所在周的日时段数组
    func weekDaysPeriods() -> [HabitDatePeriod] {
        return HabitDatePeriod.weekDaysPeriods(containing: self.date, firstWeekday: self.firstWeekday)
    }
    
    static func weekDaysPeriods(containing date: Date = .now,
                                firstWeekday: Weekday = .firstWeekday) -> [HabitDatePeriod] {
        let dates = date.thisWeekDays(firstWeekday: firstWeekday.rawValue)
        return dates.map { dayDate in
            HabitDatePeriod(date: dayDate, mode: .day)
        }
    }
}

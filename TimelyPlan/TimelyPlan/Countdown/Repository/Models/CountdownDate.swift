//
//  CountdownDate.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation

/// 倒数日日期类型
enum CountdownDateType: Int, CaseIterable, TPMenuRepresentable {
    
    /// 公历
    case gregorian = 0
    
    /// 阴历（农历）
    case lunar
    
    static func titles() -> [String] {
        return ["Gregorian", "Lunar"]
    }
    
    /// 对应日历
    var calendar: Calendar {
        switch self {
        case .gregorian:
            return Calendar(identifier: .gregorian)
        case .lunar:
            return Calendar(identifier: .chinese)
        }
    }
    
    /// 是否为阴历
    var isLunar: Bool {
        return self == .lunar
    }
}

/// 倒数日日期
struct CountdownDate: Equatable {
    
    /// 日期类型（公历 / 农历）
    var type: CountdownDateType
    
    /// 日期（统一以公历日期存储）
    var targetDate: Date
    
    /// 是否为农历闰月（仅农历类型有效）
    var isLeapMonth: Bool

    init(type: CountdownDateType = .gregorian,
         targetDate: Date = .now,
         isLeapMonth: Bool = false) {
        self.type = type
        self.targetDate = targetDate.startOfDay()
        self.isLeapMonth = isLeapMonth
    }
    
    // MARK: - Getters
    /// 是否为农历
    var isLunar: Bool {
        return type.isLunar
    }
    
    /// 农历日期（农历年以对应公历年份表示）
    var lunarComponents: (year: Int, month: Int, day: Int, isLeapMonth: Bool)? {
        return TPLunarDateHelper.lunarComponents(from: targetDate)
    }
    
    /// 显示文本（公历显示公历日期，农历显示干支年月日）
    var displayText: String {
        switch type {
        case .gregorian:
            return targetDate.yearMonthDayString
        case .lunar:
            guard let lunar = lunarComponents else {
                return targetDate.yearMonthDayString
            }
            
            /// 如：甲辰年(2024)闰二月廿九
            let yearText = LunarCalendar.getChineseYearStemBranch(year: lunar.year)
            let monthText = TPLunarDateHelper.monthName(month: lunar.month,
                                                        isLeapMonth: lunar.isLeapMonth)
            let dayText = TPLunarDateHelper.dayName(day: lunar.day)
            return "\(yearText)年(\(lunar.year))\(monthText)\(dayText)"
        }
    }
    
    var day: Int {
        switch type {
        case .gregorian:
            return targetDate.day
        case .lunar:
            return lunarComponents?.day ?? targetDate.day
        }
    }
    
    // MARK: - 里程碑
    /// 根据传入的里程碑获取对应的新日期（里程碑日期位于目标日期之前）
    /// - Parameter milestone: 里程碑（包含间隔数值与单位）
    /// - Returns: 里程碑对应的日期（沿用当前日期类型），间隔或单位缺失时返回 nil
    func date(for milestone: CountdownMilestone) -> CountdownDate? {
        guard let interval = milestone.interval, interval > 0, let unit = milestone.unit else {
            return nil
        }
        
        let component: Calendar.Component
        switch unit {
        case .hour:
            component = .hour
        case .day:
            component = .day
        case .week:
            component = .weekOfYear
        case .month:
            component = .month
        case .year:
            component = .year
        }
        
        /// 农历目标日期按农历日历偏移，公历目标日期按公历日历偏移
        guard let date = type.calendar.date(byAdding: component,
                                            value: interval,
                                            to: targetDate) else {
            return nil
        }
        
        let isLeapMonth = isLunar
            ? (TPLunarDateHelper.lunarComponents(from: date)?.isLeapMonth ?? false)
            : false
        return CountdownDate(type: type, targetDate: date, isLeapMonth: isLeapMonth)
    }
}

/// 农历月份
struct TPLunarMonth {
    
    /// 农历月（1-12）
    let month: Int
    
    /// 是否为闰月
    let isLeapMonth: Bool
    
    /// 该月天数（29 或 30）
    let numberOfDays: Int
    
    /// 显示名称（闰月带“闰”前缀）
    var displayName: String {
        return TPLunarDateHelper.monthName(month: month, isLeapMonth: isLeapMonth)
    }
}

/// 农历日期工具
enum TPLunarDateHelper {
    
    /// 农历日历
    static let chineseCalendar = Calendar(identifier: .chinese)
    
    /// 公历日历
    static let gregorianCalendar = Calendar(identifier: .gregorian)
    
    /// 农历新年缓存（key：公历年份）
    private static let lunarNewYearCache = TPLunarValueCache<Date>()
    
    /// 农历年月份缓存（key：公历年份）
    private static let lunarMonthsCache = TPLunarValueCache<[TPLunarMonth]>()
    
    /// 农历日名称
    static let lunarDayNames = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                                "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                                "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    
    /// 农历月名称（如：正月 / 闰二月）
    static func monthName(month: Int, isLeapMonth: Bool) -> String {
        let index = month - 1
        guard Date.lunarMonthStrings.indices.contains(index) else {
            return "\(month)"
        }
        
        let name = Date.lunarMonthStrings[index]
        return isLeapMonth ? "闰\(name)" : name
    }
    
    /// 农历日名称（如：廿九）
    static func dayName(day: Int) -> String {
        return lunarDayNames[safe: day - 1] ?? "\(day)"
    }
    
    /// 农历新年（正月初一）对应的公历日期
    /// - Parameter gregorianYear: 农历年所在的公历年份
    static func lunarNewYear(gregorianYear: Int) -> Date? {
        if let cached = lunarNewYearCache.value(forKey: gregorianYear) {
            return cached
        }
        
        var components = DateComponents()
        components.year = gregorianYear
        components.month = 1
        components.day = 1
        guard let firstDay = gregorianCalendar.date(from: components) else {
            return nil
        }
        
        /// 农历新年一定落在公历 1 月 21 日 ~ 2 月 21 日之间
        var date = gregorianCalendar.startOfDay(for: firstDay)
        for _ in 0..<60 {
            if isLunarNewYear(date) {
                lunarNewYearCache.setValue(date, forKey: gregorianYear)
                return date
            }
            
            guard let nextDate = date.dateByAddingDays(1) else {
                return nil
            }
            
            date = nextDate
        }
        
        return nil
    }
    
    /// 是否为农历正月初一
    static func isLunarNewYear(_ date: Date) -> Bool {
        /// 请求 .month 时 Foundation 会自动带出 isLeapMonth
        let components = chineseCalendar.dateComponents([.month, .day], from: date)
        return components.month == 1 && components.day == 1 && components.isLeapMonth != true
    }
    
    /// 指定农历年（以对应公历年份表示）的月份列表（包含闰月）
    static func months(ofLunarYear year: Int) -> [TPLunarMonth] {
        if let cached = lunarMonthsCache.value(forKey: year) {
            return cached
        }
        
        guard let startDate = lunarNewYear(gregorianYear: year),
              let endDate = lunarNewYear(gregorianYear: year + 1) else {
            return []
        }
        
        /// 农历月只有 29（小月）或 30（大月）天，因此按「月」推进即可，
        /// 无需逐日遍历整年（约 354 次历法换算 → 约 13 次）。
        var results = [TPLunarMonth]()
        var monthStart = startDate
        while monthStart < endDate {
            let components = chineseCalendar.dateComponents([.month, .day], from: monthStart)
            guard let numberOfDays = lunarMonthLength(from: monthStart) else {
                break
            }
            
            results.append(TPLunarMonth(month: components.month ?? 1,
                                        isLeapMonth: components.isLeapMonth ?? false,
                                        numberOfDays: numberOfDays))
            
            guard let nextMonthStart = monthStart.dateByAddingDays(numberOfDays) else {
                break
            }
            
            monthStart = nextMonthStart
        }
        
        if results.count > 0 {
            lunarMonthsCache.setValue(results, forKey: year)
        }
        
        return results
    }
    
    /// 农历月的天数（29 或 30）
    /// - Parameter monthStart: 该农历月的初一
    /// - Note: 小月的第 29 天、大月的第 30 天即为下月初一，最多两次历法换算即可确定
    static func lunarMonthLength(from monthStart: Date) -> Int? {
        for numberOfDays in [29, 30] {
            guard let nextMonthStart = monthStart.dateByAddingDays(numberOfDays) else {
                continue
            }
            
            if chineseCalendar.dateComponents([.day], from: nextMonthStart).day == 1 {
                return numberOfDays
            }
        }
        
        return nil
    }
    
    /// 指定日期所在农历月的天数（29 或 30）
    static func lunarMonthLength(containing date: Date) -> Int? {
        guard let components = lunarComponents(from: date) else {
            return nil
        }
        
        return months(ofLunarYear: components.year).first {
            $0.month == components.month && $0.isLeapMonth == components.isLeapMonth
        }?.numberOfDays
    }
    
    /// 农历日期转公历日期
    static func gregorianDate(lunarYear: Int,
                              month: Int,
                              day: Int,
                              isLeapMonth: Bool) -> Date? {
        guard let startDate = lunarNewYear(gregorianYear: lunarYear) else {
            return nil
        }
        
        /// 累加目标月份之前所有月份的天数，定位到目标月的初一，再推算到目标日
        var offsetDays = 0
        for lunarMonth in months(ofLunarYear: lunarYear) {
            if lunarMonth.month == month, lunarMonth.isLeapMonth == isLeapMonth {
                let clampedDay = min(max(day, 1), lunarMonth.numberOfDays)
                guard let date = startDate.dateByAddingDays(offsetDays + clampedDay - 1) else {
                    return nil
                }
                
                return gregorianCalendar.startOfDay(for: date)
            }
            
            offsetDays += lunarMonth.numberOfDays
        }
        
        return nil
    }
    
    /// 公历日期转农历日期
    /// - Returns: 农历年（以对应公历年份表示）、农历月、农历日、是否闰月
    static func lunarComponents(from date: Date) -> (year: Int, month: Int, day: Int, isLeapMonth: Bool)? {
        let components = chineseCalendar.dateComponents([.month, .day], from: date)
        guard let month = components.month, let day = components.day else {
            return nil
        }
        
        let gregorianYear = gregorianCalendar.component(.year, from: date)
        var lunarYear = gregorianYear
        /// 公历 1、2 月可能还处于上一个农历年
        if let newYear = lunarNewYear(gregorianYear: gregorianYear), date < newYear {
            lunarYear = gregorianYear - 1
        }
        
        return (lunarYear, month, day, components.isLeapMonth ?? false)
    }
}

/// 农历换算结果缓存（按公历年份缓存，线程安全）
///
/// 农历换算需要逐日遍历历法（如推算农历新年最多遍历 60 天、统计某农历年各月天数需遍历约 354 天），
/// 列表里同一批事项通常落在少数几个年份上，缓存后可将「每事项一次」的遍历降为「每年份一次」。
private final class TPLunarValueCache<Value> {
    
    private let lock = NSLock()
    private var storage: [Int: Value] = [:]
    
    func value(forKey key: Int) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }
    
    func setValue(_ value: Value, forKey key: Int) {
        lock.lock()
        defer { lock.unlock() }
        storage[key] = value
    }
}

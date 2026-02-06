//
//  Date+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/18.
//

import Foundation

extension Date {
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    var nanosecond: Int {
        return Calendar.current.component(.nanosecond, from: self)
    }
    
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    var weekdayOrdinal: Int {
        return Calendar.current.component(.weekdayOrdinal, from: self)
    }
    
    var weekOfMonth: Int {
        return Calendar.current.component(.weekOfMonth, from: self)
    }
    
    var weekOfYear: Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }
    
    var yearForWeekOfYear: Int {
        return Calendar.current.component(.yearForWeekOfYear, from: self)
    }
    
    var quarter: Int {
        return Calendar.current.component(.quarter, from: self)
    }
    
    var isLeapYear: Bool {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        return ((year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0)))
    }
    
    var isToday: Bool {
        let today = Date()
        return isInSameDayAs(today)
    }
    
    var isYesterday: Bool {
        if let added = Calendar.current.date(byAdding: .day, value: 1, to: self) {
            return added.isToday
        }
        
        return false
    }
    
    var isTomorrow: Bool {
        if let added = Calendar.current.date(byAdding: .day, value: -1, to: self) {
            return added.isToday
        }
        
        return false
    }
    
    /// 返回一个去除秒数新的Date对象
    func dateByRemovingSeconds() -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: components)
    }
    
    /// 返回一个去除分和秒的Date对象
    func dateByRemovingMinuteAndSecond() -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        return calendar.date(from: components)
    }
    
    /// 根据新的 hour 和 minute 创建一个新的 Date 对象
    func date(withHour hour: Int, minute: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        dateComponents.hour = hour // 设置新的 hour
        dateComponents.minute = minute // 设置新的 minute
        dateComponents.second = 0
        return calendar.date(from: dateComponents)
    }
    
    func dateByAddingYears(_ years: Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: years, to: self)
    }
    
    func dateByAddingMonths(_ months: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: months, to: self)
    }
    
    func dateByAddingWeeks(_ weeks: Int) -> Date? {
        return Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self)
    }
    
    func dateByAddingDays(_ days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: self)
    }
    
    func dateByAddingHours(_ hours: Int) -> Date? {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self)
    }
    
    func dateByAddingMinutes(_ minutes: Int) -> Date? {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)
    }
    
    func dateByAddingSeconds(_ seconds: Int) -> Date? {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)
    }
    
    func stringWithFormat(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    func stringWithFormat(_ format: String, timeZone: TimeZone?, locale: Locale?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let timeZone = timeZone {
            formatter.timeZone = timeZone
        }
        if let locale = locale {
            formatter.locale = locale
        }
        return formatter.string(from: self)
    }
    
    func stringWithISOFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: self)
    }
    
    static func date(withString dateString: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }
    
    static func date(withString dateString: String, format: String, timeZone: TimeZone?, locale: Locale?) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let timeZone = timeZone {
            formatter.timeZone = timeZone
        }
        if let locale = locale {
            formatter.locale = locale
        }
        return formatter.date(from: dateString)
    }
    
    static func date(withISOFormatString dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: dateString)
    }
}

extension Date {
    
    /// 日期当日的范围
    func rangeOfThisDay() -> DateRange {
        let fromDate = startOfDay()
        let toDate = endOfDay()
        return DateRange(startDate: fromDate, endDate: toDate)
    }
    
    /// 所在周日期范围
    func rangeOfThisWeek(firstWeekday: Weekday) -> DateRange {
        let fromDate = firstDayOfWeek(firstWeekday: firstWeekday.rawValue).startOfDay()
        let toDate = fromDate.dateByAddingDays(6)?.endOfDay()
        return DateRange(startDate: fromDate, endDate: toDate)
    }
    
    /// 所在月的日期范围
    func rangeOfThisMonth() -> DateRange {
        let startDate = firstDayOfMonth().startOfDay()
        let numberOfDays = numberOfDaysInMonth()
        let endDate = startDate.dateByAddingDays(numberOfDays - 1)?.endOfDay()
        return DateRange(startDate: startDate, endDate: endDate)
    }
    
    /// 所在年的日期范围
    func rangeOfThisYear() -> DateRange {
        return DateRange(startDate: startOfYear(), endDate: endOfYear())
    }
    
    /// 所在最近七天日期范围（包含今日）
    func rangeOfLatestSevenDays() -> DateRange {
        let endDate = endOfDay()
        let startDate = endDate.dateByAddingDays(-6)?.startOfDay()
        return DateRange(startDate: startDate, endDate: endDate)
    }
}

extension Date {
    
    /// 获取日期在一天已经过的秒数
    func offset() -> Int {
        let date = self.startOfDay()
        return Int(self.timeIntervalSince(date))
    }
    
    /// 去除秒的时间偏移
    var offsetWithoutSeconds: Int {
        let offset = offset()
        return offset - self.second
    }
    
    /// 将时、分、秒替换为当前的时、分、秒
    func dateByReplacingTimeWithCurrent() -> Date {
        return self.dateByReplacingTime(with: Date())
    }
    
    func dateByReplacingTime(with otherDate: Date) -> Date {
        let calendar = Calendar.current
        let otherComponents = calendar.dateComponents([.hour, .minute, .second], from: otherDate)
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        dateComponents.hour = otherComponents.hour
        dateComponents.minute = otherComponents.minute
        dateComponents.second = otherComponents.second
        return calendar.date(from: dateComponents) ?? self
    }
    
    func dateByReplacingDayWithToday() -> Date {
        return self.dateByReplacingDay(with: Date())
    }
    
    func dateByReplacingDay(with otherDate: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute, .second], from: self)
        components.year = otherDate.year
        components.month = otherDate.month
        components.day = otherDate.day
        return calendar.date(from: components) ?? self
    }
    
    /// 替换当前日期的月和天
    func dateByReplacingMonthAndDay(month: Int, day: Int) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.month = month
        components.day = day
        return calendar.date(from: components) ?? self
    }
    
    /// 根据一天中时间偏移（时、分、秒）重新获得一个新日期
    func dateWithTimeOffset(_ timeOffset: Duration) -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        dateComponents.hour = timeOffset.hour
        dateComponents.minute = timeOffset.minute
        dateComponents.second = timeOffset.second
        return calendar.date(from: dateComponents) ?? self
    }
}

//
//  TaskAlarm.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/9.
//

import Foundation
import UIKit

public class TaskAlarm: NSObject, NSCopying, Codable {
    
    /// 绝对日期
    var absoluteDate: Date?
    
    /// （天，周）间隔
    var interval: Interval?
    
    /// 时间偏移
    var offset: Offset?
    
    var intervalType: IntervalType {
        return interval?.type ?? .dayBefore
    }
    
    var intervalCount: Int {
        return interval?.count ?? 0
    }
    
    var offsetType: OffsetType {
        return offset?.type ?? .relative
    }
    
    var offsetDuration: Duration {
        return offset?.duration ?? 0
    }
    
    /// 间隔类型
    enum IntervalType: Int, Codable {
        case dayBefore  /// 几天前
        case weekBefore /// 几周前
    
        func unit(for count: Int) -> String {
            let unit: String
            switch self {
            case .dayBefore:
                unit = count > 1 ? "Days" : "Day"
            case .weekBefore:
                unit = count > 1 ? "Weeks" : "Week"
            }
            
            return unit
        }
        
        func localizedUnit(for count: Int) -> String {
            let unit = unit(for: count)
            return resGetString(unit)
        }
    }
    
    struct Interval: Codable, Hashable {
        
        /// 间隔类型
        var type: IntervalType = .dayBefore
        
        /// 间隔数目
        var count: Int = 0
        
        // MARK: - Hashable
        func hash(into hasher: inout Hasher) {
            hasher.combine(type)
            hasher.combine(count)
        }
        
        // MARK: - Equatable
        static func == (lhs: Interval, rhs: Interval) -> Bool {
            return lhs.type == rhs.type && lhs.count == rhs.count
        }
    }
    
    enum OffsetType: Int, Codable {
        case absolute /// 绝对偏移，相对一天 00:00 的时间
        case relative /// 相对偏移，相对任务开始时间点的偏移秒数
    }
    
    struct Offset: Codable, Hashable {
        
        /// 偏移类型
        var type: OffsetType = .absolute
        
        /// 偏移时长（秒）
        var duration: Duration = 0
        
        // MARK: - Hashable
        func hash(into hasher: inout Hasher) {
             hasher.combine(self.type)
             hasher.combine(self.duration)
        }
        
        // MARK: - Equatable
        static func == (lhs: Offset, rhs: Offset) -> Bool {
            return lhs.type == rhs.type && lhs.duration == rhs.duration
        }
        
        /// 获取偏移所对应的日期
        static func date(with duration: Duration) -> Date {
            let date = Date()
            return date.startOfDay().dateByAddingSeconds(duration)!
        }
    }
    
    convenience init(absoluteDate: Date) {
        self.init()
        self.absoluteDate = absoluteDate
        self.interval = nil
        self.offset = nil
    }
    
    convenience init(daysAbsolute: (daysBefore: Int, duration: Int)) {
        self.init()
        self.absoluteDate = nil
        self.interval = Interval(type: .dayBefore, count: daysAbsolute.daysBefore)
        self.offset = Offset(type: .absolute, duration: daysAbsolute.duration)
    }
    
    convenience init(weeksAbsolute: (weeksBefore: Int, duration: Int)) {
        self.init()
        self.absoluteDate = nil
        self.interval = Interval(type: .weekBefore, count: weeksAbsolute.weeksBefore)
        self.offset = Offset(type: .absolute, duration: weeksAbsolute.duration)
    }
    
    convenience init(daysRelative: (daysBefore: Int, duration: Int)) {
        self.init()
        self.absoluteDate = nil
        self.interval = Interval(type: .dayBefore, count: daysRelative.daysBefore)
        self.offset = Offset(type: .relative, duration: daysRelative.duration)
    }
    
    convenience init(weeksRelative: (weeksBefore: Int, duration: Int)) {
        self.init()
        self.absoluteDate = nil
        self.interval = Interval(type: .weekBefore, count: weeksRelative.weeksBefore)
        self.offset = Offset(type: .relative, duration: weeksRelative.duration)
    }
    
    convenience init(interval: Interval, offset: Offset) {
        self.init()
        self.absoluteDate = nil
        self.interval = interval
        self.offset = offset
    }
    
    convenience init(offset: Offset) {
        self.init()
        self.absoluteDate = nil
        self.interval = nil
        self.offset = offset
    }
    
    // MARK: - 等同性判断
    public  override var hash: Int {
        var hasher = Hasher()
        hasher.combine(absoluteDate)
        hasher.combine(interval)
        hasher.combine(offset)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TaskAlarm else { return false }
        if self === other { return true }
        return absoluteDate == other.absoluteDate &&
        interval == other.interval && offset == other.offset
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = TaskAlarm()
        copy.absoluteDate = absoluteDate
        copy.interval = interval
        copy.offset = offset
        return copy
    }
}

extension TaskAlarm: Comparable {
    
    public static func < (lhs: TaskAlarm, rhs: TaskAlarm) -> Bool {
        // 首先比较绝对日期是否存在
        if lhs.absoluteDate != nil && rhs.absoluteDate == nil {
            return true
        } else if lhs.absoluteDate == nil && rhs.absoluteDate != nil {
            return false
        }
        
        if let lDate = lhs.absoluteDate, let rDate = rhs.absoluteDate {
            return lDate < rDate
        }
        
        // 其次比较偏移类型
        if lhs.offsetType == .absolute && rhs.offsetType == .relative {
            return true
        } else if lhs.offsetType == .relative && rhs.offsetType == .absolute {
            return false
        }
        
        /// 两个绝对偏移比较
        /// 左提醒提前天数
        let lInterval = lhs.intervalCount
        var lDays: Int = lInterval
        if lhs.interval?.type == .weekBefore {
            lDays = lInterval * 7
        }
        
        /// 右提醒提前天数
        let rInterval = rhs.intervalCount
        var rDays: Int = rInterval
        if rhs.interval?.type == .weekBefore {
            rDays = rInterval * 7
        }
        
        if lhs.offsetType == .absolute && rhs.offsetType == .absolute {
            if lDays != rDays {
                return lDays > rDays
            }
            /// 偏移越小，绝对时间越在前
            return lhs.offsetDuration < rhs.offsetDuration
        }
        
        if lhs.offsetType == .relative && rhs.offsetType == .relative {
            if lDays != rDays {
                return lDays > rDays
            }
            
            /// 偏移越大，越在前
            return lhs.offsetDuration > rhs.offsetDuration
        }
        
        return false
    }
}

extension TaskAlarm {
    
    /// 富文本标题
    func attributedTitle(for eventDate: Date?, badgeColor: UIColor = .primary) -> ASAttributedString? {
        guard let title = title(for: eventDate) else {
            return nil
        }
        
        var earlyDaysCount = -intervalCount
        if offsetType == .relative {
            if let eventDate = eventDate,
                let alarmDate = alarmDate(for: eventDate) {
                earlyDaysCount = eventDate.daysBetween(alarmDate)  
            }
        }
        
        if earlyDaysCount != 0 {
            return title.byAppend(badge: "\(earlyDaysCount)", color: badgeColor)
        }
        
        return "\(title)"
    }
    
    func attributedSubtitle(for eventDate: Date?) -> ASAttributedString? {
        let subtitle: ASAttributedString = "\(subtitle(for: eventDate) ?? "")"
        return subtitle
    }
    
    private func title(for eventDate: Date?) -> String? {
        if offsetType == .relative {
            return relativeTitle(for: eventDate)
        } else {
            return absoluteTitle(for: eventDate)
        }
    }
    
    
    func subtitle(for eventDate: Date? = nil) -> String? {
        if offsetType == .relative {
            return relativeSubtitle(for: eventDate)
        } else {
            return absoluteSubtitle(for: eventDate)
        }
    }
    
    /// 绝对提醒标题
    private func absoluteTitle(for eventDate: Date? = nil) -> String? {
        return offsetDuration.timeString
    }
    
    /// 绝对提醒副标题
    private func absoluteSubtitle(for eventDate: Date? = nil) -> String? {
        guard offsetType == .absolute else {
            return nil
        }
        
        let intervalCount = intervalCount
        if intervalCount == 0 {
            return resGetString("On the day")
        }
        
        var format: String
        if intervalType == .weekBefore {
            if intervalCount > 1 {
                format = resGetString("%ld weeks before")
            } else {
                format = resGetString("%ld week before")
            }
        } else {
            if intervalCount > 1 {
                format = resGetString("%ld days early")
            } else {
                format = resGetString("%ld day early")
            }
        }
        
        return String(format: format, intervalCount)
    }
    
    
    func relativeTitle(for eventDate: Date? = nil) -> String? {
        guard let alarmDate = alarmDate(for: eventDate) else {
            return nil
        }

        return alarmDate.timeString
    }
    
    /// 相对提醒标题
    func relativeSubtitle(for eventDate: Date? = nil) -> String? {
        let count = intervalCount
        let duration = offsetDuration
        if count == 0 && duration == 0 {
            /// 准时
            return resGetString("On time")
        }
        
        /// 提前
        var intervalText: String = ""
        if count > 0 {
            var intervalFormat: String
            if intervalType == .dayBefore{
                intervalFormat = resGetString("%ldd")
            } else {
                intervalFormat = resGetString("%ldw")
            }
            
            intervalText = String(format: intervalFormat, count)
        }
        
        let durationText = duration > 0 ? duration.localizedTitle : ""
        let title = intervalText + durationText
        return String(format: resGetString("%@ early"), title)
    }
    
    func alarmDate(for eventDate: Date?) -> Date? {
        return Self.alarmDate(for: eventDate, interval: interval, offset: offset)
    }
    
    /// 根据事件日期获取提醒日期
    private static func alarmDate(for eventDate: Date?,
                                  interval: Interval?,
                                  offset: Offset?) -> Date? {
        guard let eventDate = eventDate else {
            return nil
        }
        
        let intervalType = interval?.type ?? .dayBefore
        let intervalCount = interval?.count ?? 0
    
        let offsetType = offset?.type ?? .absolute
        let offsetDuration = offset?.duration ?? 0
        
        var daysCount = 0
        if intervalType == .dayBefore {
            daysCount = intervalCount
        } else {
            daysCount = intervalCount * DAYS_PER_WEEK
        }
        
        var date = eventDate.dateByAddingDays(-daysCount)
        if offsetType == .absolute {
            /// 绝对时间
            date = date?.dateWithTimeOffset(offsetDuration)
        } else {
            /// 相对时间
            date = date?.dateByAddingSeconds(-offsetDuration)
        }

        return date
    }
    
    
    func info(with eventDate: Date?) -> String? {
        
        guard let intervalString = subtitle(for: eventDate) else {
            return nil
        }
        
        var timeString: String?
        if offsetType == .relative {
            timeString = relativeTitle(for: eventDate)
        } else {
            timeString = offsetDuration.timeString
        }
        
        if let timeString = timeString {
            return "\(intervalString)(\(timeString))"
        }
        
        return nil
    }
}

extension Array where Element == TaskAlarm {
    
    var absoluteAlarms: [TaskAlarm] {
        return self.filter { $0.offsetType == .absolute }
    }
    
    var relativeAlarms: [TaskAlarm] {
        return self.filter { $0.offsetType == .relative }
    }
    
    /// 删除数组中固定间提醒
    mutating func removeAbsoluteAlarms() {
        self.removeAll(where: { $0.offsetType == .absolute})
    }
    
    /// 删除相对时间提醒
    mutating func removeRelativeAlarms() {
        self.removeAll(where: { $0.offsetType == .relative})
    }
    
    /// 根据事件日期获取数组中Alarm对应的提醒日期数组
    func alarmDates(for eventDate: Date) -> [Date] {
        var dates = [Date]()
        for alarm in self {
            if let date = alarm.alarmDate(for: eventDate) {
                dates.append(date)
            }
        }
    
        return dates
    }
}

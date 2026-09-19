//
//  CountdownEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

/// 倒数日事件的 CoreData 属性键
struct CountdownEventKey {
    static let identifier = "identifier"
    static let eventType = "eventType"
    static let dateType = "dateType"
    static let isLeapMonth = "isLeapMonth"
    static let order = "order"
    static let name = "name"
    static let emoji = "emoji"
    static let colorHex = "colorHex"
    static let targetDate = "targetDate"
    static let note = "note"
    static let reminderJSON = "reminderJSON"
    static let timePlanJSON = "timePlanJSON"
    static let myDayDisplayMode = "myDayDisplayMode"
    static let calendarDisplayMode = "calendarDisplayMode"
    static let includesStartDate = "includesStartDate"
    static let isArchived = "isArchived"
}

/// 倒数日事项在“我的一天”与日历中的显示方式
///
/// 全部模式仅使用一个 `Int16` 字段（`code`）落库解析：
/// - `0`：不显示（默认值）
/// - `-1`：当日显示
/// - `-2`：一直显示
/// - `> 0`：提前 N 天显示（N 即编码值，由用户自定义，取值 1...99）
/// - 其它负值：按默认的不显示处理
enum CountdownDisplayMode: Equatable, Hashable {
    
    /// 不显示
    case none
    
    /// 当日显示
    case onTheDay
    
    /// 提前 N 天显示（取值限制在 1...99）
    case daysBefore(Int)
    
    /// 一直显示
    case always
    
    // MARK: - 编码
    /// 不显示的编码值（默认值）
    static let noneCode: Int16 = 0
    
    /// 当日显示的编码值
    static let onTheDayCode: Int16 = -1
    
    /// 一直显示的编码值
    static let alwaysCode: Int16 = -2
    
    /// 可自定义的提前天数范围
    static let daysRange: ClosedRange<Int> = 1...99
    
    /// 将提前天数限制在可自定义范围内
    static func validDays(_ days: Int) -> Int {
        return min(max(days, daysRange.lowerBound), daysRange.upperBound)
    }
    
    /// 是否一直显示
    var isAlwaysVisible: Bool {
        return self == .always
    }
    
    /// 提前显示的天数（不显示与一直显示时无提前天数）
    var advanceDays: Int? {
        switch self {
        case .none, .always:
            return nil
        case .onTheDay:
            return 0
        case .daysBefore(let days):
            return Self.validDays(days)
        }
    }
    
    /// 落库编码值
    var code: Int16 {
        switch self {
        case .none:
            return Self.noneCode
        case .onTheDay:
            return Self.onTheDayCode
        case .daysBefore(let days):
            return Int16(Self.validDays(days))
        case .always:
            return Self.alwaysCode
        }
    }
    
    /// 由落库编码值解析（提前天数越界时收敛到 1...99，其它非法负值按不显示处理）
    init(code: Int16) {
        switch code {
        case Self.noneCode:
            self = .none
        case Self.onTheDayCode:
            self = .onTheDay
        case Self.alwaysCode:
            self = .always
        case 1...:
            self = .daysBefore(Self.validDays(Int(code)))
        default:
            self = .none
        }
    }
    
    // MARK: - Getters
    /// 标题
    var title: String {
        switch self {
        case .none:
            return resGetString("Do Not Show")
        case .onTheDay:
            return resGetString("On the Day")
        case .daysBefore(let days):
            let format: String
            if days > 1 {
                format = resGetString("%ld Days Early")
            } else {
                format = resGetString("%ld Day Early")
            }
            
            return String(format: format, Self.validDays(days))
        case .always:
            return resGetString("Always Show")
        }
    }
    
    /// 预设模式（菜单选项，自定义天数由用户输入）
    static let presetModes: [CountdownDisplayMode] = [.none,
                                                      .onTheDay,
                                                      .daysBefore(3),
                                                      .daysBefore(7),
                                                      .always]
}

/// 倒数日事件
class CountdownEvent: NSObject,
                      TPHexColorConvertible,
                      SortableIdentifiable {
    
    /// 事件唯一标识
    var identifier: String
    
    /// 事件类型
    var type: CountdownEventType
    
    /// 排序因子
    var order: Int64
    
    /// 事件名称
    var name: String?
    
    /// 事件表情
    var emoji: String?
    
    /// 事件颜色
    var colorHex: String?
    
    /// 倒数日日期（日期类型 + 日期 + 闰月）
    var date: CountdownDate
    
    /// 正数计数是否包含选中日期当天（+1）
    var includesStartDate: Bool
    
    /// 备注
    var note: String?
    
    /// 在“我的一天”中的显示方式
    var myDayDisplayMode: CountdownDisplayMode
    
    /// 在日历中的显示方式
    var calendarDisplayMode: CountdownDisplayMode
    
    /// 提醒 JSON 字符串
    private let reminderJSON: String?
    
    /// 提醒（懒加载，从 JSON 反序列化）
    private(set) lazy var reminder: TaskReminder? = {
        guard let json = reminderJSON else {
            return nil
        }
        
        return TaskReminder.model(with: json)
    }()
    
    /// 时间计划 JSON 字符串
    private let timePlanJSON: String?
    
    /// 时间计划（懒加载，从 JSON 反序列化，默认不重复）
    private(set) lazy var timePlan: CountdownTimePlan = {
        if let json = timePlanJSON, let timePlan = CountdownTimePlan.model(with: json) {
            return timePlan
        }
        
        return CountdownTimePlan(type: .none)
    }()
    
    /// 是否已归档
    var isArchived: Bool
    
    init(identifier: String = UUID().uuidString,
         type: CountdownEventType = .countdown,
         order: Int64 = 0,
         name: String? = nil,
         emoji: String? = nil,
         colorHex: String? = nil,
         date: CountdownDate = CountdownDate(),
         includesStartDate: Bool = false,
         note: String? = nil,
         myDayDisplayMode: CountdownDisplayMode = .none,
         calendarDisplayMode: CountdownDisplayMode = .none,
         reminderJSON: String? = nil,
         timePlanJSON: String? = nil,
         isArchived: Bool = false) {
        self.identifier = identifier
        self.type = type
        self.order = order
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.date = date
        self.includesStartDate = includesStartDate
        self.note = note
        self.myDayDisplayMode = myDayDisplayMode
        self.calendarDisplayMode = calendarDisplayMode
        self.reminderJSON = reminderJSON
        self.timePlanJSON = timePlanJSON
        self.isArchived = isArchived
        super.init()
    }
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return identifier
    }
    
    // MARK: - Getters
    /// 目标日期（公历）
    var targetDate: Date {
        get {
            return date.targetDate
        }
        
        set {
            date.targetDate = newValue
        }
    }
    
    /// 显示名称
    var displayName: String {
        return name ?? resGetString("Untitled Countdown")
    }
    
    /// 相对于当前日期的下一个发生日（不重复时即为目标日期）
    var occuranceDate: CountdownDate {
        guard let rule = timePlan.regularRule,
              let nextDate = rule.nextPlanDate(from: Date(), startDate: date) else {
            return date
        }
        
        return nextDate
    }
    
    /// 距离下一个发生日的天数（正数为剩余天数，负数为已经过去的天数）
    var remainingDays: Int {
        return Date.days(fromDate: Date(), toDate: occuranceDate.targetDate)
    }
    
    /// 目标日期是否已经过去
    var isExpired: Bool {
        return remainingDays < 0
    }
    
    /// 是否有提醒
    var hasReminder: Bool {
        guard let reminder = reminder, reminder.hasAlarm else {
            return false
        }
        
        return true
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(targetDate)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CountdownEvent else { return false }
        if self === other { return true }
        return editingEvent == other.editingEvent
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? CountdownEvent {
            return self.identifier == other.identifier
                && self.targetDate == other.targetDate
        }
        
        return false
    }
}

extension CountdownEvent {
    
    /// 默认颜色
    static var defaultColor: UIColor {
        return CountdownConfig.countdownEventDefaultColor
    }
}

/// 编辑倒数日事件
struct CountdownEditingEvent: Equatable {
    
    /// 事件类型
    var type: CountdownEventType = .countdown
    
    /// 事件名称
    var name: String?
    
    /// 事件表情
    var emoji: String = CountdownConfig.defaultEmoji
    
    /// 事件颜色
    var color: UIColor = CountdownConfig.countdownEventDefaultColor
    
    /// 倒数日日期（日期类型 + 日期 + 闰月）
    var date: CountdownDate
    
    /// 正数计数是否包含选中日期当天（+1）
    var includesStartDate: Bool = false
    
    /// 提醒
    var reminder: TaskReminder?
    
    /// 时间计划（nil 表示不重复）
    var timePlan: CountdownTimePlan?
    
    /// 备注
    var note: String?
    
    /// 在“我的一天”中的显示方式
    var myDayDisplayMode: CountdownDisplayMode = .none
    
    /// 在日历中的显示方式
    var calendarDisplayMode: CountdownDisplayMode = .none
    
    init(type: CountdownEventType = .countdown,
         date: CountdownDate = CountdownDate(),
         includesStartDate: Bool = false,
         myDayDisplayMode: CountdownDisplayMode = .none,
         calendarDisplayMode: CountdownDisplayMode = .none) {
        self.type = type
        self.date = date
        self.includesStartDate = includesStartDate
        self.myDayDisplayMode = myDayDisplayMode
        self.calendarDisplayMode = calendarDisplayMode
    }
    
    /// 目标日期（公历）
    var targetDate: Date {
        get {
            return date.targetDate
        }
        
        set {
            date.targetDate = newValue
        }
    }
    
    // MARK: - Equatable
    static func == (lhs: CountdownEditingEvent, rhs: CountdownEditingEvent) -> Bool {
        return lhs.type == rhs.type
            && lhs.name == rhs.name
            && lhs.emoji == rhs.emoji
            && lhs.color == rhs.color
            && lhs.date == rhs.date
            && lhs.includesStartDate == rhs.includesStartDate
            && lhs.note == rhs.note
            && lhs.myDayDisplayMode == rhs.myDayDisplayMode
            && lhs.calendarDisplayMode == rhs.calendarDisplayMode
            && lhs.reminder == rhs.reminder
            && lhs.timePlan == rhs.timePlan
    }
    
    /// 相对于当前日期的下一个发生日（不重复时即为目标日期）
    var occuranceDate: CountdownDate {
        guard let rule = timePlan?.regularRule,
              let nextDate = rule.nextPlanDate(from: Date(), startDate: date) else {
            return date
        }
        
        return nextDate
    }
}

// MARK: - 编辑倒数日
extension CountdownEvent {
    
    /// 编辑事件
    var editingEvent: CountdownEditingEvent {
        var event = CountdownEditingEvent(type: type,
                                          date: date,
                                          includesStartDate: includesStartDate,
                                          myDayDisplayMode: myDayDisplayMode,
                                          calendarDisplayMode: calendarDisplayMode)
        event.name = name
        event.emoji = emoji ?? CountdownConfig.defaultEmoji
        event.color = color ?? CountdownConfig.countdownEventDefaultColor
        event.note = note
        /// 提醒深拷贝，避免编辑过程中修改原事件
        event.reminder = reminder?.copy() as? TaskReminder
        /// 不重复时不携带时间计划
        if let planType = timePlan.type, planType != .none {
            event.timePlan = timePlan
        }
        
        return event
    }
    
    /// 判断编辑内容是否与当前事件相同
    func isSameEvent(as editingEvent: CountdownEditingEvent) -> Bool {
        return self.editingEvent == editingEvent
    }
}

extension Array where Element == CountdownEvent {
    
    /// 所有标识
    var identifiers: [String] {
        return self.map { $0.identifier }
    }
}

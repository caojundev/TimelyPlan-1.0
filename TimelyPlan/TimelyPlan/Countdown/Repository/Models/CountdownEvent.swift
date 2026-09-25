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
    static let countingType = "countingType"
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
    static let timeUnit = "timeUnit"
    static let isArchived = "isArchived"
}

/// 倒数日事件
class CountdownEvent: NSObject,
                      TPHexColorConvertible,
                      SortableIdentifiable {
    
    /// 倒数日计数类型
    ///
    /// 用于描述事件的计数方向：
    /// - `countdown`：倒数（距离目标日期还剩多少天）
    /// - `countUp`：正数（从起始日期已经过去多少天）
    enum CountingType: Int, TPMenuRepresentable {
        
        /// 倒数
        case countdown = 0
        
        /// 正数
        case countUp
        
        // MARK: - Getters
        /// 标题本地化键
        var titleKey: String {
            return "countdown.counting.\(String(describing: self))"
        }
        
        /// 标题
        var title: String {
            return resGetString(titleKey)
        }
    }
    
    /// 事件唯一标识
    var identifier: String
    
    /// 事件类型
    var type: CountdownEventType
    
    /// 计数类型（倒数 / 正数）
    var countingType: CountingType
    
    /// 排序因子
    var order: Int64
    
    /// 事件名称
    var name: String?
    
    /// 事件表情
    var emoji: String?
    
    /// 事件颜色
    var colorHex: String?
    
    /// 倒数日日期（日期类型 + 日期 + 闰月）
    let date: CountdownDate
    
    /// 正数计数是否包含选中日期当天（+1）
    var includesStartDate: Bool
    
    /// 时间单位
    var timeUnit: CountdownTimeUnit
    
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
         countingType: CountingType = .countdown,
         order: Int64 = 0,
         name: String? = nil,
         emoji: String? = nil,
         colorHex: String? = nil,
         date: CountdownDate = CountdownDate(),
         includesStartDate: Bool = false,
         timeUnit: CountdownTimeUnit = .days,
         note: String? = nil,
         myDayDisplayMode: CountdownDisplayMode = .none,
         calendarDisplayMode: CountdownDisplayMode = .none,
         reminderJSON: String? = nil,
         timePlanJSON: String? = nil,
         isArchived: Bool = false) {
        self.identifier = identifier
        self.type = type
        self.countingType = countingType
        self.order = order
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.date = date
        self.includesStartDate = includesStartDate
        self.timeUnit = timeUnit
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
        return date.targetDate
    }
    
    /// 显示名称
    var displayName: String {
        return name ?? resGetString("Untitled Countdown")
    }
    
    /// 相对于当前日期的下一个发生日（不重复时即为目标日期）
    ///
    /// 交叉历法（尤其农历按年 / 按月重复）的推算是高开销计算（内部会遍历整个农历年），
    /// 而列表在渲染、单元格复用与多次刷新时会重复读取同一事项，因此这里对结果做一次缓存，
    /// 避免重复推算；`date` 变化时会自动失效。
    var occuranceDate: CountdownDate {
        let today = Date().startOfDay()
        if let cachedOccuranceDate = cachedOccuranceDate, cachedOccuranceDay == today {
            return cachedOccuranceDate
        }
        
        let occuranceDate: CountdownDate
        if effectiveCountingType == .countdown {
            occuranceDate = timePlan.nextPlanDate(from: Date(), startDate: date) ?? date
        } else {
            occuranceDate = date
        }
        
        cachedOccuranceDate = occuranceDate
        cachedOccuranceDay = today
        return occuranceDate
    }
    
    /// 下一个发生日缓存（`date` 变化时失效）
    private var cachedOccuranceDate: CountdownDate?
    
    /// 发生日缓存对应的日期（跨天时失效）
    private var cachedOccuranceDay: Date?
    
    /// 距离下一个发生日的天数
    var remainingDays: Int {
        return CountdownCalculator.days(referenceDate: .now,
                                        targetDate: occuranceDate.targetDate,
                                        countingType: effectiveCountingType,
                                        includeStartDate: includesStartDate)
    }
    
    /// 距离下一个发生日的剩余时间（按事项的时间单位换算后的结构化结果）
    ///
    /// 正数计数且包含起始日时，起始日计为第 1 天，等价于把参照日期（今天）后移一天后再换算。
    var remainingTimeResult: CountdownCalculator.TimeResult {
        return remainingTimeResult(with: .now)
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
        }
        
        return false
    }
    
    // MARK: - Getters
    
    /// 动态计算的生效计数类型
    ///
    /// 与编辑页的显隐条件保持一致（`CountdownGeneralEditSectionController.showsCountingTypeCellItem`）：
    /// 仅「目标日期在今天或已过去 + 存在重复规则」时，用户设置的 `countingType` 才有效；
    /// 其余情况（未来日期、或不重复）该属性会被忽略，统一按倒数（`countdown`）处理。
    var effectiveCountingType: CountingType {
        let isTodayOrPastDate = date.targetDate < Date().endOfDay()
        let hasRepeat = timePlan.type != nil && timePlan.type != CountdownTimePlanType.none
        guard isTodayOrPastDate, hasRepeat else {
            return isTodayOrPastDate ? .countUp : .countdown
        }
        
        return countingType
    }
    
    /// 显示日期对应的发生日（倒数取不早于该日的下一个发生日，正数取目标日期）
    func occurrenceDate(on day: Date) -> CountdownDate {
        switch effectiveCountingType {
        case .countUp:
            return date
        case .countdown:
            if day.isToday {
                /// 今天直接返回发生日
                return occuranceDate
            } else {
                /// 计算 day 对应的下一个发生日
                return timePlan.nextPlanDate(from: day, startDate: date) ?? date
            }
        }
    }
    
    func remainingTimeResult(with referenceDate: Date = .now) -> CountdownCalculator.TimeResult {
        var referenceDate = referenceDate
        if effectiveCountingType == .countUp, includesStartDate {
            referenceDate = referenceDate.dateByAddingDays(1) ?? referenceDate
        }
        
        return CountdownCalculator.timeResult(fromDate: referenceDate,
                                              toDate: occuranceDate.targetDate,
                                              timeUnit: timeUnit)
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
    
    /// 计数类型（倒数 / 正数）
    var countingType: CountdownEvent.CountingType = .countdown
    
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
    
    /// 时间单位
    var timeUnit: CountdownTimeUnit = .days
    
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
         countingType: CountdownEvent.CountingType = .countdown,
         date: CountdownDate = CountdownDate(),
         includesStartDate: Bool = false,
         timeUnit: CountdownTimeUnit = .days,
         myDayDisplayMode: CountdownDisplayMode = .none,
         calendarDisplayMode: CountdownDisplayMode = .none) {
        self.type = type
        self.countingType = countingType
        self.date = date
        self.includesStartDate = includesStartDate
        self.timeUnit = timeUnit
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
            && lhs.countingType == rhs.countingType
            && lhs.name == rhs.name
            && lhs.emoji == rhs.emoji
            && lhs.color == rhs.color
            && lhs.date == rhs.date
            && lhs.includesStartDate == rhs.includesStartDate
            && lhs.timeUnit == rhs.timeUnit
            && lhs.note == rhs.note
            && lhs.myDayDisplayMode == rhs.myDayDisplayMode
            && lhs.calendarDisplayMode == rhs.calendarDisplayMode
            && lhs.reminder == rhs.reminder
            && lhs.timePlan == rhs.timePlan
    }
    
    /// 相对于当前日期的下一个发生日（不重复时即为目标日期）
    var occuranceDate: CountdownDate {
        guard let timePlan = timePlan,
              let nextDate = timePlan.nextPlanDate(from: Date(), startDate: date) else {
            return date
        }
        
        return nextDate
    }
}

// MARK: - 类型预设
extension CountdownEditingEvent {
    
    /// 按事项类型生成预设编辑信息
    /// - 生日 / 纪念日 / 年龄 / 节日：默认按年重复
    /// - 生日 / 纪念日：默认当天 9:00 提醒
    /// - 倒数日：不预设重复与提醒
    /// - Parameter type: 事项类型
    /// - Returns: 携带类型预设的编辑信息
    static func preset(for type: CountdownEventType) -> CountdownEditingEvent {
        var event = CountdownEditingEvent(type: type)
        event.emoji = type.emoji
        event.timePlan = presetTimePlan(for: type)
        event.reminder = presetReminder(for: type)
        return event
    }
    
    /// 事项类型对应的预设重复规则（nil 表示不重复）
    /// - Parameter type: 事项类型
    static func presetTimePlan(for type: CountdownEventType) -> CountdownTimePlan? {
        switch type {
        case .countdown:
            /// 倒数日按所选日期单次计算
            return nil
        case .anniversary, .birthday, .age, .holiday:
            /// 纪念日 / 生日 / 年龄 / 节日均按年重复
            return CountdownTimePlan(type: .yearly)
        }
    }
    
    /// 事项类型对应的预设提醒（nil 表示无提醒）
    /// - Parameter type: 事项类型
    static func presetReminder(for type: CountdownEventType) -> TaskReminder? {
        switch type {
        case .birthday, .anniversary:
            /// 生日 / 纪念日默认当天 9:00 提醒
            let reminder = TaskReminder()
            reminder.startAlarms = [TaskAlarm(daysAbsolute: (0, 9 * SECONDS_PER_HOUR))]
            return reminder
        case .countdown, .age, .holiday:
            return nil
        }
    }
}

// MARK: - 编辑倒数日
extension CountdownEvent {
    
    /// 编辑事件
    var editingEvent: CountdownEditingEvent {
        var event = CountdownEditingEvent(type: type,
                                          countingType: countingType,
                                          date: date,
                                          includesStartDate: includesStartDate,
                                          timeUnit: timeUnit,
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

// MARK: - 倒数日事项变更

/// 倒数日事项改变
enum CountdownEventChange: Equatable {
    
    /// 内容（名称、日期、提醒、重复、显示方式等整体更新）
    case content(oldValue: CountdownEditingEvent, newValue: CountdownEditingEvent)
}

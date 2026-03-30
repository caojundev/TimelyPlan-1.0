//
//  RepeatRule.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/8.
//

import Foundation

/// 重复类型
enum RepeatType: String, Codable, TPMenuRepresentable {
    case none    /// 不重复

    case daily   /// 每天
    case weekly  /// 每周
    case weekday /// 每周工作日(周一至周五)
    case weekend /// 每周周末（周六，周日）
    case monthly /// 每周
    case yearly  /// 每年

    case lunarYearly  /// 农历每年
    case legalWorkday /// 法定工作日
    case ebbinghaus   /// 艾宾浩斯（遗忘曲线）
    
    case custom       /// 自定义
    
    var title: String {
        let title: String
        switch self {
        case .weekday:
            title = "Every Weekday"
        case .weekend:
            title = "Every Weekend"
        case .lunarYearly:
            title = "Lunar Yearly"
        case .legalWorkday:
            title = "Official Working Days"
        case .ebbinghaus:
            title = "Ebbinghaus Forgetting Curve"
        default:
            title = rawValue.capitalized
        }
        
        return resGetString(title)
    }
    
    func subtitle(for eventDate: Date? = nil) -> String? {
        let date = eventDate ?? Date()
        switch self {
        case .weekly:
            return date.weekdaySymbol()
        case .monthly:
            return date.dayOfTheMonthOrdinalSymbol(prefix: "the ", suffix: " day")
        case .yearly:
            return date.monthDayString
        case .lunarYearly:
            return date.lunarMonthDayString
        case .legalWorkday:
            return resGetString("Skip Public Holidays")
        case .weekday:
            return resGetString("Monday-Friday")
        case .weekend:
            return resGetString("Saturday, Sunday")
        default:
            return nil
        }
    }
}

extension RepeatType {
    
    func recurrenceRule(for eventDate: Date) -> RecurrenceRule? {
        switch self {
        case .daily:
            return RecurrenceRule(frequency: .daily, interval: 1)
        case .weekly:
            let dayOfTheWeek = RepeatDayOfWeek(dayOfTheWeek: Weekday(date: eventDate))
            return RecurrenceRule(frequency: .weekly, interval: 1, daysOfTheWeek: [dayOfTheWeek])
        case .weekday:
            let daysOfTheWeek = RepeatDayOfWeek.weekdayDays()
            return RecurrenceRule(frequency: .weekly, interval: 1, daysOfTheWeek: daysOfTheWeek)
        case .weekend:
            let daysOfTheWeek = RepeatDayOfWeek.weekendDays()
            return RecurrenceRule(frequency: .weekly, interval: 1, daysOfTheWeek: daysOfTheWeek)
        case .monthly:
            let daysOfTheMonth = [eventDate.day]
            return RecurrenceRule(frequency: .monthly, interval: 1, daysOfTheMonth: daysOfTheMonth)
        case .yearly:
            let daysOfTheMonth = [eventDate.day]
            let monthsOfTheYear = [eventDate.month]
            return RecurrenceRule(frequency: .yearly, interval: 1, daysOfTheMonth: daysOfTheMonth, monthsOfTheYear: monthsOfTheYear)
        default:
            return nil
        }
    }
}

/// 重复规则
public class RepeatRule: NSObject, NSCopying, Codable, AttributedDescriptable {
    
    /// 类型
    var type: RepeatType?
    
    /// 规则
    var recurrenceRule: RecurrenceRule?
    
    /// 结束
    var end: RepeatEnd?
    
    /// 数目
    var count: Int?
    
    init(type: RepeatType?, recurrenceRule:RecurrenceRule?, end: RepeatEnd?, count: Int? = nil) {
        super.init()
        self.type = type
        self.recurrenceRule = recurrenceRule
        self.end = end
        self.count = count
    }
    
    /// 重复标题
    func title(for eventDate: Date?) -> String? {
        let type = self.type ?? .none
        if type == .custom {
            /// 自定义重复标题
            return recurrenceRule?.title
        }
        
        return type.title
    }
    
    func subtitle(for eventDate: Date?) -> String? {
        var strings = [String]()
        let type = self.type ?? .none
        /// 规则文本
        var ruleString: String?
        if type == .custom {
            ruleString = recurrenceRule?.subtitle
        } else {
            ruleString = type.subtitle(for: eventDate)
        }
        
        if let ruleString = ruleString {
            strings.append(ruleString)
        }
        
        /// 结束文本
        if let endString = attributedEndInfo?.value.string {
            strings.append(endString)
        }
        
        let repeatCountInfo = repeatCountInfo()
        strings.append(repeatCountInfo)
        
        return strings.joined(separator: ", ")
    }
    
    /// 返回第几次重复信息
    func repeatCountInfo() -> String {
        /// 当前重复次数
        var repeatCount = count ?? 0
        if repeatCount < 0 {
            repeatCount = 0
        }
        
        let ordinalIndex = repeatCount + 1
        let format = ordinalIndex.ordinalSuffixFormat(suffix: " time")
        return String(format: resGetString(format), ordinalIndex)
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(type)
        hasher.combine(recurrenceRule)
        hasher.combine(end)
        hasher.combine(count)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? RepeatRule else { return false }
        if self === other { return true }
        return type == other.type &&
                recurrenceRule == other.recurrenceRule &&
                end == other.end &&
                count == other.count
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = RepeatRule(type: type,
                              recurrenceRule: recurrenceRule,
                              end: end,
                              count: count)
        return copy
    }
    
    // MARK: - Attributed Info
    func attributedInfo(imageColor: UIColor = .secondaryLabel,
                        imageSize: CGSize = .size(3),
                        showCountInfo: Bool = true) -> ASAttributedString? {
        guard self.type != RepeatType.none else {
            return nil
        }
        
        guard let image = resGetImage("schedule_repeat_24") else {
            return nil
        }
        
        let trailingText = showCountInfo ? repeatCountInfo() : nil
        let string: ASAttributedString = .string(image: image,
                                                 imageSize: imageSize,
                                                 imageColor: imageColor,
                                                 trailingText: trailingText,
                                                 separator: nil)
        return string
    }
    
    /// 结束描述
    private var attributedEndInfo: ASAttributedString? {
        guard let end = end else {
            return nil
        }
        
        if let endDate = end.endDate {
            let format: String = resGetString("until %@")
            let dateString: ASAttributedString = "\(endDate.yearMonthDayString, highlightedTextColor)"
            return .string(format: format, attributedParameters: [dateString])
        }
        
        if let occurrenceCount = end.occurrenceCount, occurrenceCount > 0 {
            let format: String
            if occurrenceCount > 1 {
                format = resGetString("%ld times")
            } else {
                format = resGetString("%ld time")
            }
            
            let countString = String(format: format, occurrenceCount)
            return "\(countString, highlightedTextColor)"
        }
        
        return nil
    }
}

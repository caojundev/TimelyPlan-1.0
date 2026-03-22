//
//  HabitTimePlan.swift
//  TimelyPlan
//
//  Created by caojun on 2023/5/22.
//

import UIKit

/// 计划类型
enum HabitTimePlanType: Int, Hashable, Codable, Equatable, TPMenuRepresentable {
    case regularly /// 定期
    
    static func titles() -> [String] {
        return ["Regularly"]
    }
}

/// 定期规则结构体
struct HabitTimePlanRegularRule: Hashable, Codable, Equatable {
    
    /// 频率
    var frequency: RepeatFrequency = .daily
    
    /// 重复间隔
    var interval: Int = 1
    
    /// 与定期规则关联的周中的几天
    var daysOfTheWeek: [Weekday]?
    
    /// 与定期规则关联的月份中的几天,（1～31，-1表示最后一天）
    var daysOfTheMonth: [Int]?
    
    init() {}
    
    init(frequency: RepeatFrequency,
         interval: Int,
         daysOfTheWeek: [Weekday]?,
         daysOfTheMonth: [Int]?) {
        self.frequency = frequency
        self.interval = interval
        switch frequency {
        case .weekly:
            self.daysOfTheWeek = daysOfTheWeek
        case .monthly:
            self.daysOfTheMonth = daysOfTheMonth
        default:
            break
        }
    }
}

/// 时间计划
public class HabitTimePlan: NSObject, Codable, NSCopying {
    
    /// 类型
    var type: HabitTimePlanType = .regularly
    
    /// 定期规则，当 type 为 regularly 时有效
    var regularRule: HabitTimePlanRegularRule?
    
    override init() {
        super.init()
    }
    
    init(regularRule: HabitTimePlanRegularRule?) {
        super.init()
        self.regularRule = regularRule
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let type = try? container.decodeIfPresent(HabitTimePlanType.self, forKey: .type) {
            self.type = type
        }

        self.regularRule = try? container.decodeIfPresent(HabitTimePlanRegularRule.self,
                                                          forKey: .regularRule)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(regularRule, forKey: .regularRule)
    }
    
    /// 描述标题
    var title: String? {
        let rule = regularRule ?? HabitTimePlanRegularRule()
        return rule.title
    }
    
    /// 副标题
    var subtitle: String? {
        let rule = regularRule ?? HabitTimePlanRegularRule()
        return rule.subtitle
    }
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case type
        case regularRule
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(type)
        hasher.combine(regularRule)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? HabitTimePlan else { return false }
        if self === other { return true }
        return type == other.type && regularRule == other.regularRule
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = HabitTimePlan()
        copy.type = type
        copy.regularRule = regularRule
        return copy
    }
}

/// 定期规则描述
extension HabitTimePlanRegularRule: AttributedDescriptable {
    
    /// 描述标题
    var title: String? {
        return intervalDescription?.value.string.capitalizedFirstLetter()
    }
    
    /// 副标题
    var subtitle: String? {
        return detailDescription?.value.string.capitalizedFirstLetter()
    }
    
    func localizedAttributedDescription() -> ASAttributedString? {
        var descriptions = [ASAttributedString]()
        if let intervalDescription = intervalDescription {
            descriptions.append(intervalDescription)
        }
        
        if let detailDescription = detailDescription {
            descriptions.append(detailDescription)
        }
        
        return descriptions.joined(separator: ", ")
    }
    
    // MARK: - Interval
    var intervalDescription: ASAttributedString? {
        return intervalDescription(interval: interval, frequency: frequency)
    }
    
    func intervalDescription(interval: Int, frequency: RepeatFrequency) -> ASAttributedString? {
        let frequencyFormat: String = resGetString("every %@")
        return .string(format: frequencyFormat, attributedParameters: [intervalAttributedString])
    }
    
    private var intervalAttributedString: ASAttributedString {
        let unit = frequency.unit(for: interval).lowercased()
        var string: String
        if interval == 1 {
            string = resGetString(unit)
        } else {
            let format: String = resGetString("%ld \(unit)")
            string = String(format: format, interval)
        }
        
        return "\(string, highlightedTextColor)"
    }
        
    // MARK: - Detail
    /// 定期详细描述信息
    var detailDescription: ASAttributedString? {
        switch frequency {
        case .daily:
            return nil
        case .weekly:
            return daysOfTheWeekDescription
        case .monthly:
            return daysOfTheMonthDescription
        default:
            return nil
        }
    }
    
    /// 周天
    var daysOfTheWeekDescription: ASAttributedString? {
        guard let symbols = daysOfTheWeek?.orderedShortSymbols else {
            return nil
        }
        
        let symbolString = symbols.joined(separator: ", ")
        let symbolAttributedString: ASAttributedString = "\(symbolString, highlightedTextColor)"
        let format: String = resGetString("on the %@")
        return .string(format: format, attributedParameters: [symbolAttributedString])
    }

    /// 月天
    var daysOfTheMonthDescription: ASAttributedString? {
        guard let daysOfTheMonth = daysOfTheMonth, daysOfTheMonth.count > 0 else {
            return nil
        }

        var symbols = [String]()
        for i in 1...31 {
           if daysOfTheMonth.contains(i) {
               let format = Date.ordinalSymbol(dayOfTheMonth: i)
               let symbol = String(format: resGetString(format), i)
               symbols.append(symbol)
           }
        }

        // 最后一天
        if daysOfTheMonth.contains(-1) {
            let lastSymbol: String = resGetString("last day")
            symbols.append(lastSymbol)
        }
        
        let symbolString = symbols.joined(separator: ", ")
        let symbolAttributedString: ASAttributedString = "\(symbolString, highlightedTextColor)"
        let format: String = resGetString("on the %@")
        
        return .string(format: format, attributedParameters: [symbolAttributedString])
    }
}

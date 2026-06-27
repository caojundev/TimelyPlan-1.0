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

extension HabitTimePlan {
    
    /// 获取特定日期之后（包括当天）最近的一个计划日
    /// - Parameters:
    ///   - date: 参考日期
    ///   - startDate: 习惯开始日期
    ///   - endDate: 习惯结束日期（nil表示永不结束）
    /// - Returns: 最近的下一个计划日，如果找不到返回nil
    func nextPlanDate(from date: Date, startDate: Date, endDate: Date? = nil) -> Date? {
        let rule = regularRule ?? HabitTimePlanRegularRule()
        let calendar = Calendar.current
        let referenceDate = max(calendar.startOfDay(for: date), calendar.startOfDay(for: startDate))
        
        let nextDate: Date?
        switch rule.frequency {
        case .daily:
            nextDate = nextDailyDate(from: referenceDate, interval: max(1, rule.interval), startDate: startDate, calendar: calendar)
            
        case .weekly:
            nextDate = nextWeeklyDate(from: referenceDate, daysOfWeek: rule.daysOfTheWeek, startDate: startDate, calendar: calendar)
            
        case .monthly:
            nextDate = nextMonthlyDate(from: referenceDate, daysOfMonth: rule.daysOfTheMonth, startDate: startDate, calendar: calendar)
            
        case .yearly:
            nextDate = nil
        }
        
        guard let nextDate = nextDate else { return nil }
        
        if let endDate = endDate {
            return nextDate <= calendar.startOfDay(for: endDate) ? nextDate : nil
        }
        
        return nextDate
    }
    
    // MARK: - Daily (O(1))
    
    private func nextDailyDate(from date: Date, interval: Int, startDate: Date, calendar: Calendar) -> Date? {
        let daysFromStart = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        
        if daysFromStart % interval == 0 {
            return date
        } else {
            let daysToAdd = interval - (daysFromStart % interval)
            return calendar.date(byAdding: .day, value: daysToAdd, to: date)
        }
    }
    
    // MARK: - Weekly (O(1))
    
    private func nextWeeklyDate(from date: Date, daysOfWeek: [Weekday]?, startDate: Date, calendar: Calendar) -> Date? {
        let targetDays = (daysOfWeek?.isEmpty ?? true)
            ? [Weekday(rawValue: calendar.component(.weekday, from: startDate))!]
            : daysOfWeek!
        
        let currentWeekday = calendar.component(.weekday, from: date)
        let sortedDays = targetDays.map { $0.rawValue }.sorted()
        
        // 查找本周内的下一个目标星期几
        for weekday in sortedDays {
            var daysToAdd = weekday - currentWeekday
            if daysToAdd < 0 {
                daysToAdd += 7  // 下周
            }
            
            if let candidateDate = calendar.date(byAdding: .day, value: daysToAdd, to: date) {
                if daysToAdd == 0 || candidateDate >= date {
                    return candidateDate
                }
            }
        }
        
        // 如果本周没有，返回下周的第一个
        if let firstWeekday = sortedDays.first {
            let daysToAdd = 7 - currentWeekday + firstWeekday
            return calendar.date(byAdding: .day, value: daysToAdd, to: date)
        }
        
        return nil
    }
    
    // MARK: - Monthly (O(n), n为daysOfMonth数量)
    
    private func nextMonthlyDate(from date: Date, daysOfMonth: [Int]?, startDate: Date, calendar: Calendar) -> Date? {
        let targetDays = (daysOfMonth?.isEmpty ?? true)
            ? [calendar.component(.day, from: startDate)]
            : daysOfMonth!
        
        let currentDay = calendar.component(.day, from: date)
        var components = calendar.dateComponents([.year, .month], from: date)
        
        // 获取当月天数
        guard let monthStart = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else { return nil }
        let daysInMonth = range.count
        
        // 查找当月内剩余的目标日期
        let sortedDays = targetDays.map { resolveDay($0, daysInMonth: daysInMonth) }.sorted()
        
        for day in sortedDays where day >= currentDay {
            components.day = day
            if let candidateDate = calendar.date(from: components) {
                return candidateDate
            }
        }
        
        // 查找下个月
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart) {
            var nextComponents = calendar.dateComponents([.year, .month], from: nextMonth)
            guard let nextRange = calendar.range(of: .day, in: .month, for: nextMonth) else { return nil }
            let nextDaysInMonth = nextRange.count
            
            let nextSortedDays = targetDays.map { resolveDay($0, daysInMonth: nextDaysInMonth) }.sorted()
            if let firstDay = nextSortedDays.first {
                nextComponents.day = firstDay
                return calendar.date(from: nextComponents)
            }
        }
        
        return nil
    }
    
    /// 处理特殊日期值（-1表示最后一天，超出范围取最后一天）
    private func resolveDay(_ day: Int, daysInMonth: Int) -> Int {
        if day == -1 { return daysInMonth }
        return min(day, daysInMonth)
    }
}

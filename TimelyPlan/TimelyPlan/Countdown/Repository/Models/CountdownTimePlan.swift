//
//  CountdownTimePlan.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/16.
//

import Foundation

/// 重复类型
enum CountdownTimePlanType: String, Codable, TPMenuRepresentable {
    case none    /// 不重复
    case daily   /// 每天
    case weekly  /// 每周
    case monthly /// 每周
    case yearly  /// 每年
    case custom  /// 自定义
    
    var title: String {
        return resGetString(rawValue.capitalized)
    }
    
    var regularRule: TaskTimePlanRegularRule? {
        switch self {
        case .daily:
            return TaskTimePlanRegularRule(frequency: .daily)
        case .weekly:
            return TaskTimePlanRegularRule(frequency: .weekly)
        case .monthly:
            return TaskTimePlanRegularRule(frequency: .monthly)
        case .yearly:
            return TaskTimePlanRegularRule(frequency: .yearly)
        default:
            return nil
        }
    }
}

/// 重复规则
struct CountdownTimePlan: Codable, Equatable {
    
    /// 类型
    var type: CountdownTimePlanType?
    
    /// 重复规则
    var recurrenceRule: TaskTimePlanRegularRule?
    
    init(type: CountdownTimePlanType, recurrenceRule: TaskTimePlanRegularRule? = nil) {
        self.type = type
        self.recurrenceRule = recurrenceRule
    }
    
    /// 生效的重复规则（自定义规则优先）
    var regularRule: TaskTimePlanRegularRule? {
        return recurrenceRule ?? type?.regularRule
    }
    
    var descriptionTitle: String? {
        guard let type = type else {
            return nil
        }
        
        if type != .custom {
            return type.title
        }
        
        /// 自定义规则
        if let rule = recurrenceRule {
            return rule.title
        }
        
        return nil
    }
}

extension TaskTimePlanRegularRule {
    
    /// 获取特定日期之后（包括当天）最近的一个计划日
    /// - Parameters:
    ///   - date: 参考日期
    ///   - startDate: 任务开始日期（包含日期类型：公历 / 农历）
    ///   - endDate: 任务结束日期（nil表示永不结束）
    /// - Returns: 最近的下一个计划日，如果找不到返回nil
    func nextPlanDate(from date: Date,
                      startDate: CountdownDate,
                      endDate: Date? = nil) -> CountdownDate? {
        /// 公历：沿用已有的计算逻辑
        if !startDate.isLunar {
            guard let nextDate = nextPlanDate(from: date,
                                              startDate: startDate.targetDate,
                                              endDate: endDate) else {
                return nil
            }
            
            return CountdownDate(type: .gregorian, targetDate: nextDate)
        }
        
        /// 农历
        return nextLunarPlanDate(from: date, startDate: startDate, endDate: endDate)
    }
    
    // MARK: - 农历
    
    /// 获取农历类型下最近的一个计划日
    private func nextLunarPlanDate(from date: Date,
                                   startDate: CountdownDate,
                                   endDate: Date? = nil) -> CountdownDate? {
        let calendar = TPLunarDateHelper.gregorianCalendar
        let referenceDate = max(calendar.startOfDay(for: date),
                                calendar.startOfDay(for: startDate.targetDate))
        
        let nextDate: Date?
        switch frequency {
        case .daily, .weekly:
            /// 按天、按周与公历逻辑一致（星期几与历法无关）
            nextDate = nextPlanDate(from: referenceDate,
                                    startDate: startDate.targetDate,
                                    endDate: nil)
            
        case .monthly:
            nextDate = nextLunarMonthlyDate(from: referenceDate, startDate: startDate)
            
        case .yearly:
            nextDate = nextLunarYearlyDate(from: referenceDate, startDate: startDate)
        }
        
        guard let nextDate = nextDate else { return nil }
        
        /// 结束日期校验
        if let endDate = endDate, nextDate > calendar.startOfDay(for: endDate) {
            return nil
        }
        
        let isLeapMonth = TPLunarDateHelper.lunarComponents(from: nextDate)?.isLeapMonth ?? false
        return CountdownDate(type: .lunar, targetDate: nextDate, isLeapMonth: isLeapMonth)
    }
    
    /// 农历按月重复：以起始日对应的农历日为重复日（即每月的初几，而非公历的几号），闰月同样参与重复
    private func nextLunarMonthlyDate(from date: Date, startDate: CountdownDate) -> Date? {
        guard let targetComponents = TPLunarDateHelper.lunarComponents(from: startDate.targetDate) else {
            return nil
        }
        
        /// 自定义规则指定的天数按农历日解释，未指定时取起始日的农历日
        let targetDays = (daysOfTheMonth?.isEmpty ?? true) ? [targetComponents.day] : daysOfTheMonth!
        
        let calendar = TPLunarDateHelper.gregorianCalendar
        let chineseCalendar = TPLunarDateHelper.chineseCalendar
        
        /// 农历一个月最多 30 天，最多向后遍历两个月即可覆盖
        var candidate = calendar.startOfDay(for: date)
        for _ in 0..<70 {
            guard let lunarDay = chineseCalendar.dateComponents([.day], from: candidate).day else {
                return nil
            }
            
            if targetDays.contains(lunarDay) {
                return candidate
            }
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: candidate) else {
                return nil
            }
            
            /// 当月不存在目标日时，与公历逻辑保持一致，落在当月最后一天
            let isLastDayOfLunarMonth = chineseCalendar.dateComponents([.day], from: nextDay).day == 1
            if isLastDayOfLunarMonth,
               targetDays.contains(-1) || targetDays.contains(where: { $0 > lunarDay }) {
                return candidate
            }
            
            candidate = nextDay
        }
        
        return nil
    }
    
    /// 农历按年重复：以起始日对应的农历月份 + 农历日重复（即每年的几月初几）
    private func nextLunarYearlyDate(from date: Date, startDate: CountdownDate) -> Date? {
        guard let targetComponents = TPLunarDateHelper.lunarComponents(from: startDate.targetDate),
              let currentLunarYear = TPLunarDateHelper.lunarComponents(from: date)?.year else {
            return nil
        }
        
        let interval = max(1, self.interval)
        let targetMonth = targetComponents.month
        let targetDay = targetComponents.day
        /// 起始日为闰月时优先在闰月重复，当年无闰月则回退到同月的普通月
        let prefersLeapMonth = startDate.isLeapMonth || targetComponents.isLeapMonth
        
        /// 按间隔定位到参考日期所在的农历年附近，最多再顺延一个间隔
        let yearsFromStart = max(0, currentLunarYear - targetComponents.year)
        var cycles = yearsFromStart / interval
        
        for _ in 0..<2 {
            let lunarYear = targetComponents.year + cycles * interval
            
            var candidate: Date? = nil
            if prefersLeapMonth {
                candidate = TPLunarDateHelper.gregorianDate(lunarYear: lunarYear,
                                                            month: targetMonth,
                                                            day: targetDay,
                                                            isLeapMonth: true)
            }
            
            if candidate == nil {
                candidate = TPLunarDateHelper.gregorianDate(lunarYear: lunarYear,
                                                            month: targetMonth,
                                                            day: targetDay,
                                                            isLeapMonth: false)
            }
            
            if let candidate = candidate, candidate >= date {
                return candidate
            }
            
            cycles += 1
        }
        
        return nil
    }
}

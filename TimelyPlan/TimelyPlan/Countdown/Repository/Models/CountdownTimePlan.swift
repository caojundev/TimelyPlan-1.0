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
    case milestone /// 里程碑
    
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
    
    /// 里程碑
    var milestones: [CountdownMilestone]?
    
    init(type: CountdownTimePlanType,
         recurrenceRule: TaskTimePlanRegularRule? = nil,
         milestones: [CountdownMilestone]? = nil) {
        self.type = type
        self.recurrenceRule = recurrenceRule
        self.milestones = milestones
    }
    
    /// 生效的重复规则（自定义规则优先）
    var regularRule: TaskTimePlanRegularRule? {
        return recurrenceRule ?? type?.regularRule
    }
    
    /// 是否有里程碑
    var hasMilestone: Bool {
        return milestones?.isEmpty == false
    }
    
    /// 描述文本（展示于重复规则条目）
    var descriptionTitle: String? {
        guard let type = type else {
            return nil
        }
        
        switch type {
        case .none, .daily, .weekly, .monthly, .yearly:
            return type.title
        case .custom:
            /// 自定义规则
            return recurrenceRule?.title
        case .milestone:
            /// 无里程碑时退化为类型标题
            return milestonesDescription ?? type.title
        }
    }
    
    /// 里程碑描述文本（按单位与间隔排序后拼接）
    var milestonesDescription: String? {
        guard let milestones = milestones, milestones.count > 0 else {
            return nil
        }
        
        return milestones.sorted().map { $0.title }.joined(separator: ", ")
    }
}

// MARK: - 计划日
extension CountdownTimePlan {
    
    /// 获取特定日期之后（包括当天）最近的一个计划日
    /// - Parameters:
    ///   - date: 参考日期
    ///   - startDate: 目标日期（包含日期类型：公历 / 农历）
    ///   - endDate: 计划结束日期（nil表示永不结束）
    /// - Returns: 最近的下一个计划日，如果找不到返回nil
    func nextPlanDate(from date: Date,
                      startDate: CountdownDate,
                      endDate: Date? = nil) -> CountdownDate? {
        /// 里程碑：取最近一个尚未到达的里程碑日
        if type == .milestone {
            return nextMilestoneDate(from: date, targetDate: startDate, endDate: endDate)
        }
        
        return regularRule?.nextPlanDate(from: date,
                                        startDate: startDate,
                                        endDate: endDate)
    }
    
    // MARK: - 里程碑
    /// 获取最近一个尚未到达的里程碑日
    /// - 里程碑日期均位于目标日期之前，取最近一个不早于参考日期的里程碑；
    ///   所有里程碑都已到达（或已越过目标日期）时返回nil
    private func nextMilestoneDate(from date: Date,
                                   targetDate: CountdownDate,
                                   endDate: Date? = nil) -> CountdownDate? {
        guard let milestones = milestones, milestones.count > 0 else {
            return nil
        }
        
        let calendar = TPLunarDateHelper.gregorianCalendar
        let referenceDate = calendar.startOfDay(for: date)
        let planEndDate = endDate.map { calendar.startOfDay(for: $0) }
        
        let milestoneDates = milestones.compactMap { $0.date(before: targetDate) }
            .filter { planEndDate == nil || $0 <= planEndDate! }
            .sorted()
        
        guard let nextDate = milestoneDates.first(where: { $0 >= referenceDate }) else {
            return nil
        }
        
        /// 里程碑沿用目标日期的日期类型
        let isLeapMonth = targetDate.isLunar
            ? (TPLunarDateHelper.lunarComponents(from: nextDate)?.isLeapMonth ?? false)
            : false
        return CountdownDate(type: targetDate.type,
                             targetDate: nextDate,
                             isLeapMonth: isLeapMonth)
    }
}

// MARK: - 里程碑日期
extension CountdownMilestone {
    
    /// 目标日期对应的里程碑日期（由目标日期向前偏移）
    /// - Parameter targetDate: 目标日期（包含日期类型：公历 / 农历）
    /// - Returns: 里程碑对应的公历日期，间隔或单位缺失时返回nil
    func date(before targetDate: CountdownDate) -> Date? {
        guard let interval = interval, interval > 0, let unit = unit else {
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
        let calendar = targetDate.type.calendar
        guard let date = calendar.date(byAdding: component,
                                       value: -interval,
                                       to: targetDate.targetDate) else {
            return nil
        }
        
        return TPLunarDateHelper.gregorianCalendar.startOfDay(for: date)
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

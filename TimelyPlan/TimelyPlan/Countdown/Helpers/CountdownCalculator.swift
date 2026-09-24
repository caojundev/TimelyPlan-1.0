//
//  CountdownCalculator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/23.
//

import Foundation

/// 倒数日计数换算后的单个时间粒度
/// 比 `CountdownTimeUnit` 更细，仅表示单一粒度（天 / 周 / 月 / 年）
enum CountdownTimeGranularity: Int {
    
    /// 天
    case day = 0
    
    /// 周
    case week
    
    /// 月
    case month
    
    /// 年
    case year
    
    /// 单位本地化键
    /// 计数结果的显示空间有限，英文使用简写（D / W / MO / Y），中文因单字已足够紧凑与完整单位一致
    var titleKey: String {
        switch self {
        case .day:
            return "countdown.unitShort.day"
        case .week:
            return "countdown.unitShort.week"
        case .month:
            return "countdown.unitShort.month"
        case .year:
            return "countdown.unitShort.year"
        }
    }
    
    /// 单位标题
    var title: String {
        return resGetString(titleKey)
    }
}

/// 倒数日计算器
class CountdownCalculator {
    
    /// 以参照日期所在日为基准计算到目标日期所在日的天数：正数为剩余天数，负数为已经过去的天数。
    static func days(referenceDate: Date,
                     targetDate: Date,
                     countingType: CountdownEvent.CountingType,
                     includeStartDate: Bool) -> Int {
        let days = abs(Date.days(fromDate: referenceDate, toDate: targetDate))
        guard countingType == .countUp, includeStartDate else {
            return days
        }
        
        return days + 1
    }
    
    // MARK: - 时间单位换算
    /// 按时间单位把两个日期之间的间隔换算为结构化结果
    ///
    /// 换算顺序为「先换算大粒度，再用剩余天数换算小粒度」，年与月按日历真实长度推算：
    /// 例如 1 月 15 日 → 3 月 20 日，先得到 2 个月（即 3 月 15 日），
    /// 再用剩余 5 天得到「2 个月 5 天」，而不是把总天数按固定 30 天 / 365 天折算。
    /// 末级粒度不足一个单位的余数会被忽略（如「月 + 周」中的零散天数）。
    ///
    /// - Parameters:
    ///   - fromDate: 起始日期
    ///   - toDate: 结束日期
    ///   - timeUnit: 时间单位，决定换算出的粒度组合
    ///   - calendar: 换算使用的日历（默认当前日历，可传入农历等其它日历）
    /// - Returns: 结构化换算结果，天数恒为非负（起始日期晚于结束日期时自动交换）
    static func timeResult(fromDate: Date,
                           toDate: Date,
                           timeUnit: CountdownTimeUnit,
                           calendar: Calendar = .current) -> TimeResult {
        let startDate = min(fromDate, toDate).startOfDay()
        let endDate = max(fromDate, toDate).startOfDay()
        var anchorDate = startDate
        var components: [TimeResult.Component] = []
        
        for granularity in timeUnit.granularities {
            let result = valueAndAnchorDate(for: granularity,
                                            from: anchorDate,
                                            to: endDate,
                                            calendar: calendar)
            anchorDate = result.anchorDate
            
            if result.value > 0 {
                components.append(TimeResult.Component(value: result.value,
                                                       granularity: granularity))
            }
        }
        
        /// 所有粒度均为 0 时保留“0 天”，保证结果始终可展示
        if components.isEmpty {
            components.append(TimeResult.Component(value: 0, granularity: .day))
        }
        
        return TimeResult(fromDate: startDate,
                          toDate: endDate,
                          timeUnit: timeUnit,
                          components: components)
    }
    
    // MARK: - 粒度换算
    /// 以指定粒度换算锚点日期到结束日期的整数值，并返回换算后的新锚点日期
    /// - Parameters:
    ///   - granularity: 时间粒度
    ///   - anchorDate: 当前锚点日期（已换算掉较大粒度的日期）
    ///   - endDate: 结束日期
    ///   - calendar: 换算使用的日历
    /// - Returns: 该粒度的整数值与剩余天数的新起点
    private static func valueAndAnchorDate(for granularity: CountdownTimeGranularity,
                                           from anchorDate: Date,
                                           to endDate: Date,
                                           calendar: Calendar) -> (value: Int, anchorDate: Date) {
        /// 锚点到结束日期的天数，非负
        let remainingDays = abs(Date.days(fromDate: anchorDate, toDate: endDate))
        
        switch granularity {
        case .day:
            return (remainingDays, endDate)
        case .week:
            /// 周为固定 7 天，不足一周的零散天数留待后续粒度或忽略
            let weeks = remainingDays / 7
            let nextAnchorDate = calendar.date(byAdding: .day,
                                               value: weeks * 7,
                                               to: anchorDate) ?? anchorDate
            return (weeks, nextAnchorDate)
        case .month:
            return wholeUnitValue(.month, from: anchorDate, to: endDate, calendar: calendar)
        case .year:
            return wholeUnitValue(.year, from: anchorDate, to: endDate, calendar: calendar)
        }
    }
    
    /// 按日历推算锚点日期到结束日期之间的完整月数 / 年数，并返回对应的新锚点日期
    /// 推算结果会收敛到不超过结束日期，避免日历四舍五入带来的越界
    private static func wholeUnitValue(_ component: Calendar.Component,
                                       from anchorDate: Date,
                                       to endDate: Date,
                                       calendar: Calendar) -> (value: Int, anchorDate: Date) {
        let difference = calendar.dateComponents([component], from: anchorDate, to: endDate)
        let value = max(component == .month ? difference.month ?? 0 : difference.year ?? 0, 0)
        var valueToUse = value
        var nextAnchorDate = calendar.date(byAdding: component, value: valueToUse, to: anchorDate) ?? anchorDate
        
        /// 越界时逐级回退（最多回退 1 次，日历推算最多偏差 1 个单位）
        while valueToUse > 0, nextAnchorDate > endDate {
            valueToUse -= 1
            nextAnchorDate = calendar.date(byAdding: component,
                                           value: valueToUse,
                                           to: anchorDate) ?? anchorDate
        }
        
        return (valueToUse, nextAnchorDate)
    }
}

extension CountdownCalculator {
    
    /// 倒数日时间单位换算结果
    struct TimeResult: Equatable {
        
        /// 换算结果中的单个组成部分（数值 + 粒度）
        struct Component: Equatable {
            
            /// 数值
            let value: Int
            
            /// 时间粒度
            let granularity: CountdownTimeGranularity
            
            /// 单位标题（英文为简写 d / w / mo / y，中文为「天 / 周 / 月 / 年」）
            var unitTitle: String {
                return granularity.title
            }
        }
        
        /// 换算的起始日期（两者中较早的一天）
        let fromDate: Date
        
        /// 换算的结束日期（两者中较晚的一天）
        let toDate: Date
        
        /// 换算使用的时间单位
        let timeUnit: CountdownTimeUnit
        
        /// 组成部分（按 年 → 月 → 周 → 天 排列，数值为 0 的组成部分已剔除）
        let components: [Component]
        
        /// 两个日期之间的总天数
        var totalDays: Int {
            return abs(Date.days(fromDate: fromDate, toDate: toDate))
        }
        
        /// 完整文本（各组成部分以「数值 + 单位」拼接，如 "1 年 2 月 3 天"）
        /// 数值与单位、组成部分之间均按本地化格式拼接，中文为 "1年2月3天"，英文为 "1y 2mo 3d"
        var text: String {
            guard let first = components.first else {
                return ""
            }
            
            return components.dropFirst().reduce(text(for: first)) { result, component in
                return joinedText(result, text(for: component))
            }
        }
        
        /// 主文本：最大粒度的「数值 + 单位」（如 "13月"、"13mo"）
        var primaryText: String {
            guard let first = components.first else {
                return ""
            }
            
            return text(for: first)
        }
        
        /// 次文本：第二个粒度的「数值 + 单位」（不存在第二个粒度时为 nil，如 "5天"、"5d"）
        var secondaryText: String? {
            guard components.count > 1 else {
                return nil
            }
            
            return text(for: components[1])
        }
        
        /// 指定粒度在结果中的数值（未包含该粒度时为 0）
        func value(of granularity: CountdownTimeGranularity) -> Int {
            return components.first { $0.granularity == granularity }?.value ?? 0
        }
        
        /// 单个组成部分的文本（数值 + 单位）
        private func text(for component: Component) -> String {
            return joinedText("\(component.value)", component.unitTitle)
        }
        
        /// 按本地化格式拼接两段文本（中文无空格，英文含空格）
        private func joinedText(_ lhs: String, _ rhs: String) -> String {
            return String(format: resGetString("%@ %@"), lhs, rhs)
        }
    }
}

extension CountdownTimeUnit {
    
    /// 该时间单位包含的时间粒度（按从大到小排列）
    var granularities: [CountdownTimeGranularity] {
        switch self {
        case .days:
            return [.day]
        case .weekDay:
            return [.week, .day]
        case .monthDay:
            return [.month, .day]
        case .monthWeek:
            return [.month, .week]
        case .yearDay:
            return [.year, .day]
        case .yearWeek:
            return [.year, .week]
        case .yearMonth:
            return [.year, .month]
        }
    }
}

//
//  CountdownMilestone.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation

struct CountdownMilestone: Codable, Hashable {
    
    /// 间隔数值，如 3
    var interval: Int?
    
    /// 间隔单位，如 .month 表示“3 个月”
    var unit: TimeUnit?
}

// MARK: - 展示
extension CountdownMilestone {
    
    /// 标题，如“3 Months”
    var title: String {
        let count = interval ?? 1
        let unit = unit ?? .day
        let unitString = unit.localizedUnit(for: count)
        return String(format: resGetString("%@ %@"), "\(count)", unitString)
    }
    
    /// 预设里程碑（按单位与间隔升序排列）
    static let presets: [CountdownMilestone] = [CountdownMilestone(interval: 100, unit: .day),
                                                CountdownMilestone(interval: 1000, unit: .day),
                                                CountdownMilestone(interval: 1, unit: .week),
                                                CountdownMilestone(interval: 1, unit: .month),
                                                CountdownMilestone(interval: 3, unit: .month),
                                                CountdownMilestone(interval: 6, unit: .month),
                                                CountdownMilestone(interval: 1, unit: .year),
                                                CountdownMilestone(interval: 2, unit: .year),
                                                CountdownMilestone(interval: 3, unit: .year)]
}

// MARK: - 排序
extension CountdownMilestone: Comparable {
    
    /// 排序因子（先单位、后间隔）
    private var sortFactor: (unit: Int, interval: Int) {
        return (unit?.rawValue ?? TimeUnit.day.rawValue, interval ?? 0)
    }
    
    static func < (lhs: CountdownMilestone, rhs: CountdownMilestone) -> Bool {
        let lhsFactor = lhs.sortFactor
        let rhsFactor = rhs.sortFactor
        if lhsFactor.unit != rhsFactor.unit {
            return lhsFactor.unit < rhsFactor.unit
        }
        
        return lhsFactor.interval < rhsFactor.interval
    }
}

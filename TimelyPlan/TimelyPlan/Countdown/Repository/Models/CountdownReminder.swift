//
//  CountdownReminder.swift
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
    static let presets: [CountdownMilestone] = [CountdownMilestone(interval: 1, unit: .week),
                                                CountdownMilestone(interval: 1, unit: .month),
                                                CountdownMilestone(interval: 3, unit: .month),
                                                CountdownMilestone(interval: 6, unit: .month),
                                                CountdownMilestone(interval: 1, unit: .year),
                                                CountdownMilestone(interval: 2, unit: .year)]
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

class CountdownReminder: TaskReminder {
    
    /// 里程碑
    var milestones: [CountdownMilestone]?
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(startAlarms)
        hasher.combine(endAlarms)
        hasher.combine(ringtone)
        hasher.combine(isConstant)
        hasher.combine(milestones)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CountdownReminder else { return false }
        if self === other { return true }
        return startAlarms == other.startAlarms
            && endAlarms == other.endAlarms
            && ringtone == other.ringtone
            && isConstant == other.isConstant
            && milestones == other.milestones
    }
    
    // MARK: - NSCopying
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = CountdownReminder()
        copy.startAlarms = startAlarms?.map { $0.copy() as! TaskAlarm }
        copy.endAlarms = endAlarms?.map { $0.copy() as! TaskAlarm }
        copy.ringtone = ringtone
        copy.isConstant = isConstant
        /// CountdownMilestone 为值类型，直接赋值即为深拷贝
        copy.milestones = milestones
        return copy
    }
}

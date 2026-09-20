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

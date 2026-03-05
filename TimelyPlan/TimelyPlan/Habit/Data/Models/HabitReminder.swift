//
//  HabitReminder.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/1.
//

import Foundation

public class HabitReminder: NSObject, NSCopying, Codable {
    
    /// 开始提醒
    var alarms: [TaskAlarm]?
    
    /// 铃声标识
    var ringtone: String?
    
    /// 如果启用，任务将不断被提醒直到你处理它
    var isConstant: Bool?
    
    /// 提醒数目
    var alarmsCount: Int {
        return alarms?.count ?? 0
    }
    
    /// 是否有提醒
    var hasAlarm: Bool {
        return alarmsCount > 0
    }
    
    init(alarms: [TaskAlarm]? = nil) {
        self.alarms = alarms
    }
    
    /// 事件日期对应的提醒日期
    func alarmDates(for eventDate: Date?) -> [Date]? {
        if let date = eventDate,
           let alarmDates = alarms?.alarmDates(for: date) {
            return alarmDates
        }
        
        return nil
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(alarms)
        hasher.combine(ringtone)
        hasher.combine(isConstant)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? HabitReminder else { return false }
        if self === other { return true }
        return alarms == other.alarms &&
                ringtone == other.ringtone &&
                isConstant == other.isConstant
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = HabitReminder()
        copy.alarms = alarms?.map{ $0.copy() as! TaskAlarm}
        copy.ringtone = ringtone
        copy.isConstant = isConstant
        return copy
    }
}

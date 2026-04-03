//
//  TaskReminder.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/2.
//

import Foundation

public class TaskReminder: NSObject, NSCopying, Codable {
    
    /// 开始提醒
    var startAlarms: [TaskAlarm]?
    
    /// 结束提醒
    var endAlarms: [TaskAlarm]?
    
    /// 铃声标识
    var ringtone: String?
    
    /// 如果启用，任务将不断被提醒直到你处理它
    var isConstant: Bool?
    
    /// 提醒数目
    var alarmsCount: Int {
        let startAlarmsCount = startAlarms?.count ?? 0
        let endAlarmsCount = endAlarms?.count ?? 0
        return startAlarmsCount + endAlarmsCount
    }
    
    /// 是否有提醒
    var hasAlarm: Bool {
        return alarmsCount > 0
    }
    
    /// 获取提醒日期对应的提醒描述
    func info(with dateInfo: TaskDateInfo) -> String? {
        var infos = [String]()
        if let startAlarmsInfo = startAlarmsInfo(with: dateInfo.startDate) {
            let description = String(format: resGetString("Start: %@"), startAlarmsInfo)
            infos.append(description)
        }

        if let endAlarmsInfo = endAlarmsInfo(with: dateInfo.endDate) {
            let description = String(format: resGetString("Due: %@"), endAlarmsInfo)
            infos.append(description)
        }
        
        guard infos.count > 0 else {
            return nil
        }
        
        return infos.joined(separator: " • ")
    }
    
    func startAlarmsInfo(with eventDate: Date?) -> String? {
        var infos = [String]()
        if let startAlarms = startAlarms, startAlarms.count > 0 {
            for startAlarm in startAlarms {
                if let info = startAlarm.info(with: eventDate) {
                    infos.append(info)
                }
            }
        }
        
        if infos.count > 0 {
            return infos.joined(separator: ", ")
        }
        
        return nil
    }
    
    func endAlarmsInfo(with eventDate: Date?) -> String? {
        var infos = [String]()
        if let endAlarms = endAlarms, endAlarms.count > 0 {
            for endAlarm in endAlarms {
                if let info = endAlarm.info(with: eventDate) {
                    infos.append(info)
                }
            }
        }
        
        if infos.count > 0 {
            return infos.joined(separator: ", ")
        }
        
        return nil
    }
    
    /// 根据日期信息更新提醒
    func update(dateInfo: TaskDateInfo) {
        if dateInfo.isAllDay {
            /// 删除相对提醒
            removeRelativeAlarms()
        } else {
            /// 删除绝对提醒
            removeAbsoluteAlarms()
        }
    }
    
    // MARK: - Private Methods
    
    /// 事件日期对应的开始提醒日期
    func startAlarmDates(for eventDate: Date?) -> [Date]? {
        if let startDate = eventDate,
           let alarmDates = startAlarms?.alarmDates(for: startDate) {
            return alarmDates
        }
        
        return nil
    }
    
    /// 事件日期对应的开始提醒日期
    func endAlarmDates(for eventDate: Date?) -> [Date]? {
        if let endDate = eventDate,
           let alarmDates = endAlarms?.alarmDates(for: endDate) {
            return alarmDates
        }
        
        return nil
    }
    
    /// 清除绝对时间提醒
    private func removeAbsoluteAlarms() {
        startAlarms?.removeAbsoluteAlarms()
        endAlarms?.removeAbsoluteAlarms()
    }
    
    /// 清除相对时间提醒
    private func removeRelativeAlarms() {
        startAlarms?.removeRelativeAlarms()
        endAlarms?.removeRelativeAlarms()
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(startAlarms)
        hasher.combine(endAlarms)
        hasher.combine(ringtone)
        hasher.combine(isConstant)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TaskReminder else { return false }
        if self === other { return true }
        return startAlarms == other.startAlarms &&
                endAlarms == other.endAlarms &&
                ringtone == other.ringtone &&
                isConstant == other.isConstant
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = TaskReminder()
        copy.startAlarms = startAlarms?.map{ $0.copy() as! TaskAlarm}
        copy.endAlarms = endAlarms?.map{ $0.copy() as! TaskAlarm}
        copy.ringtone = ringtone
        copy.isConstant = isConstant
        return copy
    }
    
}

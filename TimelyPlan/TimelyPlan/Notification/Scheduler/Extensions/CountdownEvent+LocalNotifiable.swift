//
//  CountdownEvent+LocalNotifiable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/22.
//

import Foundation

struct CountdownNotificationKey {
    /// 事件发生日期
    static let planDate = "planDate"
}

extension CountdownEvent: LocalNotifiable {
    
    var taskIdentifier: String {
        return identifier
    }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        guard !isArchived, let reminder = reminder, reminder.hasAlarm else {
            return []
        }
        
        let title = displayName
        let bodyFormat = resGetString("Countdown Reminder at %@")
        let userInfo: [String: Any] = [TaskNotificationKey.taskType: TaskNotificationType.countdown.rawValue,
                                       TaskNotificationKey.taskIdentifier: taskIdentifier]
        var configs = [TaskNotificationConfig]()
        let eventDates = nextOccurrenceDates()
        for eventDate in eventDates {
            guard let alarmDates = reminder.startAlarmDates(for: eventDate) else {
                continue
            }
            
            /// 设置发生日期
            var userInfo = userInfo
            userInfo[CountdownNotificationKey.planDate] = eventDate
            
            for alarmDate in alarmDates {
                let body = String(format: bodyFormat, alarmDate.timeString)
                let config = TaskNotificationConfig(
                    taskIdentifier: taskIdentifier,
                    title: title,
                    body: body,
                    triggerDate: alarmDate,
                    sound: .default,
                    userInfo: userInfo
                )
                
                configs.append(config)
            }
        }
        
        return configs
    }
}

// MARK: - 发生日期
extension CountdownEvent {
    
    /// 获取未来若干个发生日期（不重复时为目标日期本身）
    /// - Parameters:
    ///   - date: 参考日期
    ///   - count: 最大数目
    /// - Returns: 升序排列的发生日期数组
    func nextOccurrenceDates(from date: Date = .now, count: Int = 3) -> [Date] {
        var dates = Set<Date>()
        let calendar = Calendar.current
        let referenceDay = calendar.startOfDay(for: date)
        
        /// 不重复：仅目标日期（且不早于参考日期）
        guard let planType = timePlan.type, planType != .none else {
            let targetDate = self.date.targetDate
            if targetDate >= referenceDay {
                dates.insert(targetDate)
            }
            
            return dates.sorted { $0 < $1 }
        }
        
        /// 重复：依次取下一个个计划日
        var referenceDate = date
        for _ in 1...count {
            guard let planDate = timePlan.nextPlanDate(from: referenceDate, startDate: self.date) else {
                break
            }
            
            dates.insert(planDate.targetDate)
            guard let nextReferenceDate = planDate.targetDate.dateByAddingDays(1) else {
                break
            }
            
            referenceDate = nextReferenceDate
        }
        
        return dates.sorted { $0 < $1 }
    }
}

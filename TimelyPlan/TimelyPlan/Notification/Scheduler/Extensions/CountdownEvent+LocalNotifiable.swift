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
        guard !isArchived, hasReminder, let reminder = reminder else {
            return []
        }
        
        let title = displayName
        let userInfo: [String: Any] = [TaskNotificationKey.taskType: TaskNotificationType.countdown.rawValue,
                                       TaskNotificationKey.taskIdentifier: taskIdentifier]
        var configs = [TaskNotificationConfig]()
        let planDates = nextOccurrenceDates()
        for planDate in planDates {
            guard let alarmDates = reminder.startAlarmDates(for: planDate.targetDate) else {
                continue
            }
            
            /// 设置发生日期
            var userInfo = userInfo
            userInfo[CountdownNotificationKey.planDate] = planDate.targetDate
            
            for alarmDate in alarmDates {
                let body = formatBodyString(planDate: planDate, alarmDate: alarmDate)
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
    
    // MARK: - 通知正文
    /// 通知正文：距离目标日期的天数 + 目标日期
    ///
    /// 例如：`3天后 • 2026年9月25日`、`明天 • 2026年9月23日`、`今天 • 2026年9月22日`
    /// - Parameters:
    ///   - planDate: 本次提醒对应的发生日期
    ///   - alarmDate: 提醒触发日期
    /// - Returns: 通知正文
    func formatBodyString(planDate: CountdownDate, alarmDate: Date) -> String {
        /// 提醒触发时距离目标日期的天数（正数为剩余天数，负数为已经过去的天数）
        let days = Date.days(fromDate: alarmDate, toDate: planDate.targetDate)
        guard days >= 0 else {
            return planDate.displayText
        }
        
        let relativeString: String
        if days == 0 {
            relativeString = resGetString("Today")
        } else if days == 1 {
            relativeString = resGetString("Tomorrow")
        } else {
            relativeString = String(format: resGetString("%@ later"), days.dayCountString)
        }
        
        return "\(relativeString) • \(planDate.displayText)"
    }
}

// MARK: - 发生日期
extension CountdownEvent {
    
    /// 获取未来若干个发生日期（不重复时为目标日期本身）
    /// - Parameters:
    ///   - date: 参考日期
    ///   - count: 最大数目
    /// - Returns: 升序排列的发生日期数组
    func nextOccurrenceDates(from date: Date = .now, count: Int = 3) -> [CountdownDate] {
        let calendar = Calendar.current
        let referenceDay = calendar.startOfDay(for: date)
        
        /// 不重复：仅目标日期（且不早于参考日期）
        guard let planType = timePlan.type, planType != .none else {
            return self.date.targetDate >= referenceDay ? [self.date] : []
        }
        
        /// 重复：依次取下一个个计划日
        var dates = [CountdownDate]()
        var seenTargets = Set<Date>()
        var referenceDate = date
        for _ in 1...count {
            guard let planDate = timePlan.nextPlanDate(from: referenceDate, startDate: self.date) else {
                break
            }
            
            /// 去重（同一目标日期只保留一次）
            if seenTargets.insert(planDate.targetDate).inserted {
                dates.append(planDate)
            }
            
            guard let nextReferenceDate = planDate.targetDate.dateByAddingDays(1) else {
                break
            }
            
            referenceDate = nextReferenceDate
        }
        
        return dates.sorted { $0.targetDate < $1.targetDate }
    }
}

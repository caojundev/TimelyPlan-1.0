//
//  GoalTask+LocalNotifiable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/8.
//

import Foundation

struct GoalNotificationKey {
    /// 计划日期
    static let planDate = "planDate"
}

extension GoalTask: LocalNotifiable {
    
    var taskIdentifier: String {
        return identifier
    }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        guard hasReminder, let reminder = reminder else {
            return []
        }
        
        let title = displayName
        let bodyFormat = resGetString("Goal Reminder at %@")
        let userInfo: [String: Any] = [TaskNotificationKey.taskType: TaskNotificationType.goal.rawValue,
                                       TaskNotificationKey.taskIdentifier: taskIdentifier]
        let sound = GoalSetting.shared.sound?.toUNNotificationSound
        
        var configs = [TaskNotificationConfig]()
        let planDates = nextPlanDates()
        for planDate in planDates {
            guard let alarmDates = reminder.alarmDates(for: planDate) else {
                continue
            }
            
            /// 设置计划日期
            var userInfo = userInfo
            userInfo[GoalNotificationKey.planDate] = planDate
            
            for alarmDate in alarmDates {
                let body = String(format: bodyFormat, alarmDate.timeString)
                let config = TaskNotificationConfig(
                    taskIdentifier: taskIdentifier,
                    title: title,
                    body: body,
                    triggerDate: alarmDate,
                    sound: sound,
                    userInfo: userInfo
                )
                
                configs.append(config)
            }
        }
        
        return configs
    }
}

// MARK: - 计划日期
extension GoalTask {
    
    /// 获取未来若干个计划日期
    func nextPlanDates(from date: Date = .now, count: Int = 3) -> [Date] {
        var dates = Set<Date>()
        var referenceDate: Date = date
        for _ in 1...count {
            guard let planDate = nextPlanDate(from: referenceDate) else {
                break
            }
            
            dates.insert(planDate)
            if let nextReferenceDate = planDate.dateByAddingDays(1) {
                referenceDate = nextReferenceDate
            } else {
                break
            }
        }
        
        return dates.sorted { $0 < $1 }
    }
    
    /// 获取特定日期之后（包括当天）最近的一个计划日
    func nextPlanDate(from date: Date) -> Date? {
        guard let startDate = dateRange.startDate else {
            return nil
        }
        
        let endDate = dateRange.endDate
        return timePlan.nextPlanDate(from: date,
                                     startDate: startDate,
                                     endDate: endDate)
    }
}

//
//  HabitPeriodItem+LocalNotifiable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/26.
//

import Foundation

struct HabitNotificationKey {
    /// 计划日期
    static let planDate = "planDate"
}

extension HabitPeriodItem: LocalNotifiable {
    
    var taskIdentifier: String {
        return habitTask.identifier
    }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        guard habitTask.shouldRemind, let reminder = habitTask.reminder else {
            return []
        }
        
        let title = habitTask.displayTitle
        let bodyFormat = resGetString("Habit Reminder at %@")
        let sound = HabitSetting.shared.sound?.toUNNotificationSound
        let userInfo: [String: Any] = [TaskNotificationKey.taskType: TaskNotificationType.habit.rawValue,
                                       TaskNotificationKey.taskIdentifier: taskIdentifier]
        var configs = [TaskNotificationConfig]()
        let planDates = habitTask.nextPlanDates()
        for planDate in planDates {
            let status = status(on: planDate)
            /// 检测状态
            guard status == .notStarted || status == .inProgress else {
                continue
            }
                
            guard let alarmDates = reminder.alarmDates(for: planDate) else {
                continue
            }
            
            /// 设置计划日期
            var userInfo = userInfo
            userInfo[HabitNotificationKey.planDate] = planDate
            
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

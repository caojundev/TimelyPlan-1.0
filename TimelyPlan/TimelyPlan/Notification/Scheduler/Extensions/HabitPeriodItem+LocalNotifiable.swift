//
//  HabitPeriodItem+LocalNotifiable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/26.
//

import Foundation

extension HabitPeriodItem: LocalNotifiable {
    
    var taskIdentifier: String {
        return habitTask.identifier
    }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        guard habitTask.shouldRemind, let reminder = habitTask.reminder else {
            return []
        }
        
        let title = habitTask.displayName
        let bodyFormat = resGetString("Habit Reminder at %@")
        
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
            
            for alarmDate in alarmDates {
                let body = String(format: bodyFormat, alarmDate.timeString)
                let config = TaskNotificationConfig(
                    taskIdentifier: taskIdentifier,
                    title: title,
                    body: body,
                    triggerDate: alarmDate
                )
                
                configs.append(config)
            }
        }
        
        return configs
    }
}

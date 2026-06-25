//
//  TodoTask+LocalNotifiable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/25.
//

import Foundation

extension TodoTask: LocalNotifiable {
    
    var taskIdentifier: String {
        return identifier
    }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        guard let schedule = schedule, let dateInfo = schedule.dateInfo else {
            return []
        }
        
        print("===============⏰===============")
        var configs = [TaskNotificationConfig]()
        if let startAlarmDates = schedule.startAlarmDates {
            print("开始提醒")
            for alarmDate in startAlarmDates {
                let title = self.name ?? resGetString("Untitled Todo Task")
//                let startDateString = dateInfo.startDate.yearMonthDayTimeString(omitYear: true,
//                                                                                showRelativeDate: true,
//                                                                                slashFormatted: false)
//                let body = "开始提醒 • \(startDateString)"
                let config = TaskNotificationConfig(
                    taskIdentifier: taskIdentifier,
                    title: title,
                    body: body,
                    triggerDate: alarmDate
                )
                
                configs.append(config)
                
                print(alarmDate.yearMonthDayTimeString(omitYear: true))
            }
        }
        
        if let endAlarmDates = schedule.endAlarmDates {
            print("结束提醒")
            for alarmDate in endAlarmDates {
                let title = self.name ?? resGetString("Untitled Todo Task")
//                let endDateString = dateInfo.endDate.yearMonthDayTimeString(omitYear: true,
//                                                                            showRelativeDate: true,
//                                                                            slashFormatted: false)
//                let body = "结束提醒 • \(endDateString)"
                let config = TaskNotificationConfig(
                    taskIdentifier: taskIdentifier,
                    title: title,
                    body: body,
                    triggerDate: alarmDate
                )
                
                configs.append(config)
                print(alarmDate.yearMonthDayTimeString(omitYear: true))
            }
        }
        
        print("================================\n")
        return configs
    }
}

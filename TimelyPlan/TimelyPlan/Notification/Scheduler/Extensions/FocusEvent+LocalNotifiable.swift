//
//  FocusEvent+LocalNotifiable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/27.
//

import Foundation

extension FocusEvent: LocalNotifiable {
    
    /// 通知专注任务类型
    static let eventIdentifier = "FocusEvent"

    var taskIdentifier: String {
        return FocusEvent.eventIdentifier
    }
    
    func getNotificationConfigs() -> [TaskNotificationConfig] {
        guard let steps = steps, steps.count > 0, isRunning else {
            return []
        }
        
        let currentDate = Date()
        var configs = [TaskNotificationConfig]()
        for step in steps {
            guard let alarmDate = step.endDate else {
                /// 未开始
                break
            }
            
            if alarmDate < currentDate {
                /// 结束日期已过
                continue
            }
            
            let title = step.name ?? resGetString("Untitled Step")
            let bodyFormat: String
            var sound: NotificationSound?
            if step.mode == .focus {
                sound = FocusSetting.shared.focusEndSound
                bodyFormat = resGetString("%@ focus ended")
            } else {
                sound = FocusSetting.shared.breakEndSound
                bodyFormat = resGetString("%@ break ended")
            }
        
            var body: String
            if Int(step.duration) > 0 {
                let durationString = step.duration.durationString()
                body = String(format: bodyFormat, durationString)
            } else {
                body = step.mode == .focus ? resGetString("Focus ended") : resGetString("Break ended")
            }
            
            let config = TaskNotificationConfig(
                taskIdentifier: taskIdentifier,
                title: title,
                body: body,
                triggerDate: alarmDate,
                sound: sound?.toUNNotificationSound
            )
            
            configs.append(config)
        }
        
        return configs
    }
}

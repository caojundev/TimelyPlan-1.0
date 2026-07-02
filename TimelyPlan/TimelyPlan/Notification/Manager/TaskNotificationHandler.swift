//
//  TaskNotificationHandler.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/1.
//

import Foundation
import UIKit

class TaskNotificationHandler: NotificationClickProcessor {
    
    func processNotificationClick(_ info: NotificationClickInfo) {
        guard let rawValue = info.userInfo[TaskNotificationKey.taskType] as? String,
              let taskType = TaskNotificationType(rawValue: rawValue)else {
            return
        }
        
        switch taskType {
        case .todo:
            processTodoNotificationClick(info)
        case .habit:
            processHabitNotificationClick(info)
        case .focus:
            processFocusNotificationClick(info)
        }
    }
    
    func processTodoNotificationClick(_ info: NotificationClickInfo) {
        guard let identifier = info.userInfo[TaskNotificationKey.taskIdentifier] as? String else {
            return
        }
        
        if let task = TodoRepository.getTask(with: identifier) {
            let taskController = TodoTaskController()
            taskController.editTask(task)
        }
    }
    
    func processHabitNotificationClick(_ info: NotificationClickInfo) {
        guard let taskIdentifier = info.userInfo[TaskNotificationKey.taskIdentifier] as? String,
              let date = info.userInfo[HabitNotificationKey.planDate] as? Date else {
            return
        }
        
        HabitRepository.fetchPeriodItem(for: taskIdentifier, on: date) { periodITem in
            guard let periodItem = periodITem else {
                return
            }

            DispatchQueue.main.async {
                HabitDayMenuPresenter.showInfoMenu(for: periodItem, on: date)
            }
        }
    }
    
    func processFocusNotificationClick(_ info: NotificationClickInfo) {
        FocusTracker.shared.showTrackingViewControllerIfNeeded()
    }
}

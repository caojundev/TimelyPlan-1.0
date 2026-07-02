//
//  TaskNotificationType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/1.
//

import Foundation

struct TaskNotificationKey {
    static let taskType = "taskType"
    static let taskIdentifier = "taskIdentifier"
}

enum TaskNotificationType: String, Codable {
    case todo
    case habit
    case focus
}

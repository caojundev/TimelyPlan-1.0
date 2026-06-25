//
//  TaskNotificationConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/22.
//

import Foundation

// MARK: - 通知配置
class TaskNotificationConfig {
    let taskIdentifier: String
    let title: String
    let body: String
    let triggerDate: Date
    var sound: UNNotificationSound?
    var badge: NSNumber?
    var userInfo: [String: Any]
    var categoryIdentifier: String?
    
    init(taskIdentifier: String,
         title: String,
         body: String,
         triggerDate: Date,
         sound: UNNotificationSound? = .default,
         badge: NSNumber? = nil,
         userInfo: [String: Any] = [:]) {
        self.taskIdentifier = taskIdentifier
        self.title = title
        self.body = body
        self.triggerDate = triggerDate
        self.sound = sound
        self.badge = badge
        self.userInfo = userInfo
    }
    
    func toNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let sound = sound { content.sound = sound }
        if let badge = badge { content.badge = badge }
        if let categoryIdentifier = categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        var enhancedUserInfo = userInfo
        enhancedUserInfo["taskIdentifier"] = taskIdentifier
        enhancedUserInfo["triggerTimestamp"] = triggerDate.timeIntervalSince1970
        content.userInfo = enhancedUserInfo
        return content
    }
    
    func toNotificationTrigger() -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
    
    var notificationId: String {
        "\(taskIdentifier)_\(Int(triggerDate.timeIntervalSince1970))"
    }
}

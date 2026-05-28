//
//  AppNotificationName.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/15.
//

import Foundation

// MARK: - 通知名称扩展
extension Notification.Name {
    static let notificationAuthorizationGranted = Notification.Name("notificationAuthorizationGranted")
    static let notificationWillEnterForeground = Notification.Name("notificationWillEnterForeground")
    static let notificationMainViewSizeDidChange = Notification.Name("notificationMainViewSizeDidChange")
}

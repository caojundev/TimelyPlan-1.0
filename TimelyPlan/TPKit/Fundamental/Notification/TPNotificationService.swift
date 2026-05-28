//
//  TPNotificationService.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/19.
//

import Foundation
import UserNotifications

class TPNotificationService {
    
    static func allowAccessIfNeeded() {
        requestAuthorization { granted in
            if !granted {
                let vc = TPNotificationAllowAccessViewController()
                vc.slideShow(from: .bottom, animated: true, completion: nil)
            } else {
                /// 发出已授权了通知
                postAuthorizationGrantedNotification()
            }
        }
    }
    
    /// 发出"已授权"通知
    static func postAuthorizationGrantedNotification() {
        NotificationCenter.default.post(
            name: .notificationAuthorizationGranted,
            object: nil,
            userInfo: ["granted": true]
        )
    }
    
    static func isAuthorized(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let granted = isGranted(settings.authorizationStatus)
                completion(granted)
            }
        }
    }
    
    private static func isGranted(_ status: UNAuthorizationStatus) -> Bool {
        let granted = (status == .authorized ||
                       status == .provisional ||
                       status == .ephemeral)
        return granted
    }
    
    /// 请求通知权限（仅在未决定时请求）
    /// - Parameter completion: 回调返回是否成功获得授权（注意：用户拒绝或已在设置中关闭也会返回 false）
    private static func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    // 首次请求
                    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if let error = error {
                            debugPrint("通知权限请求失败: \(error.localizedDescription)")
                        }
                        
                        DispatchQueue.main.async {
                            completion?(granted)
                        }
                    }
                } else {
                    let granted = isGranted(settings.authorizationStatus)
                    completion?(granted)
                }
            }
        }
    }
}

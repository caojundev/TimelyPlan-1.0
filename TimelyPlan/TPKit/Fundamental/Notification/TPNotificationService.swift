//
//  TPNotificationService.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/19.
//

import Foundation
import UserNotifications

class TPNotificationService {

    /// 请求授权
    static func requestAuthorization(completion: ((Bool) -> Void)?) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }
    
    /// 弹窗允许通知
    static func allowAccessIfNeeded() {
        requestAuthorization { granted in
            if !granted {
                let vc = TPNotificationAllowAccessViewController()
                vc.slideShow(from: .bottom, animated: true, completion: nil)
            }
        }
    }
    
    static func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            
            // 用户已经授权
           let content = UNMutableNotificationContent()
           content.title = "新消息"
           content.body = "TimeFlow发动的第一条通知"
            
            // 获取自定义铃声的 URL
            let soundURL = Bundle.main.url(forResource: "happy", withExtension: "wav")
            if let soundURL = soundURL {
                let soundName = UNNotificationSoundName(rawValue: soundURL.lastPathComponent)
                content.sound = UNNotificationSound(named: soundName)
            } else {
                content.sound = UNNotificationSound.default
            }
            
           // 设置通知触发器
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0,
                                                           repeats: false)
           // 创建通知请求
           let request = UNNotificationRequest(identifier: "localNotification",
                                               content: content,
                                               trigger: trigger)
           UNUserNotificationCenter.current().add(request) { error in
               if let error = error {
                   print("添加通知请求失败：\(error.localizedDescription)")
               } else {
                   print("添加通知请求成功")
               }
           } 
        }
    }
}

//
//  FocusEventNotificationService.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/13.
//

import Foundation
import UserNotifications

typealias FocusStepFireInfo = (step: FocusStep, date: Date)

/// 通知任务类型键值
let kNotiTaskTypeKey = "TaskType"

/// 通知专注任务类型
let kNotiFocusTaskTypeValue = "Focus"
let kNotiFocusEventIDKey = "FocusEventID"

class FocusEventNotificationService: TPNotificationService {
    
    static func scheduleNotifications(forEvent event: FocusEvent) {
        requestAuthorization { granted in
            guard granted else {
                return
            }
            
            /// 删除待定通知
            removeAllFocusPendingNotifications {
                addRequests(forEvent: event)
            }
        }
    }
    
    /// 添加事件的通知请求
    private static func addRequests(forEvent event: FocusEvent) {
        guard let requests = notificationRequests(forEvent: event), requests.count > 0 else {
            return
        }
        
        UNUserNotificationCenter.current().addRequests(requests) {
            debugPrint("***********添加 \(requests.count) 个通知***********")
            requests.printTriggerDates()
            debugPrint("******************************")
        }
    }
    
    private static func notificationRequests(forEvent event: FocusEvent) -> [UNNotificationRequest]? {
        guard let fireInfos = fireInfos(forEvent: event), let eventID = event.identifier else {
            return nil
        }

        var requests: [UNNotificationRequest] = []
        for fireInfo in fireInfos {
            let content = UNMutableNotificationContent()
            content.userInfo = [kNotiTaskTypeKey: kNotiFocusTaskTypeValue,
                                kNotiFocusEventIDKey: eventID]
            content.title = fireInfo.step.name ?? resGetString("New Message")
            content.body = "结束"
            
            // 获取自定义铃声的 URL
            let soundURL = Bundle.main.url(forResource: "happy", withExtension: "wav")
            if let soundURL = soundURL {
                let soundName = UNNotificationSoundName(rawValue: soundURL.lastPathComponent)
                content.sound = UNNotificationSound(named: soundName)
            } else {
                content.sound = UNNotificationSound.default
            }
            
            // 设置通知触发器
            let trigger = UNCalendarNotificationTrigger(dateMatching: fireInfo.date.components,
                                                        repeats: false)
            // 创建通知请求
            let requestID = fireInfo.step.identifier ?? UUID().uuidString
            let request = UNNotificationRequest(identifier: requestID,
                                                content: content,
                                                trigger: trigger)
            requests.append(request)
        }
        
        return requests
    }
    
    private static func fireInfos(forEvent event: FocusEvent) -> [FocusStepFireInfo]? {
        guard let steps = event.steps, steps.count > 0, event.isRunning  else {
            return nil
        }
        
        let currentDate = Date()
        var infos = [FocusStepFireInfo]()
        for step in steps {
            guard let endDate = step.endDate else {
                /// 未开始
                break
            }
            
            if endDate < currentDate {
                /// 结束日期已过
                continue
            }
            
            infos.append((step, endDate))
        }
        
        if infos.count == 0 {
            return nil
        }
        
        return infos
    }
    
    /// 删除专注事件所有的待定通知
    static func removeAllPendingNotifications(forEvent event: FocusEvent,
                                              completion:(() -> Void)? = nil) {
        guard let eventID = event.identifier else {
            DispatchQueue.main.async {
                completion?()
            }
            
            return
        }
        
        let pairs: [KeyValuePair] = [(kNotiTaskTypeKey, kNotiFocusTaskTypeValue),
                                     (kNotiFocusEventIDKey, eventID)]
        removeAllPendingNotifications(with: pairs, completion: completion)
    }
    
    /// 删除所有待定的专注通知
    static func removeAllFocusPendingNotifications(completion:(() -> Void)? = nil) {
        let pairs = [(kNotiTaskTypeKey, kNotiFocusTaskTypeValue)]
        removeAllPendingNotifications(with: pairs, completion: completion)
    }
    
    /// 删除所有符合键值对的待定通知
    static func removeAllPendingNotifications(with keyValuePairs: [KeyValuePair],
                                              completion:(() -> Void)?) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            if requests.count > 0 {
                let identifiers = requests.identifiers(with: keyValuePairs)
                center.removePendingNotificationRequests(withIdentifiers: identifiers)
                debugPrint("============删除 \(identifiers.count) 个待定通知============")
                requests.printTriggerDates()
                debugPrint("=================================")
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
}

typealias KeyValuePair = (key: String, value: String)

extension Array where Element == UNNotificationRequest {
    
    func filterUserInfo(withKey key: String, value: String) -> [UNNotificationRequest] {
        return self.filter { request in
            guard let aValue = request.content.userInfo[key] as? String else {
                return false
            }
            
            return aValue == value
        }
    }
    
    func identifiers(with keyValuePairs: [KeyValuePair]) -> [String] {
        let requests = filterUserInfo(with: keyValuePairs)
        return requests.map { $0.identifier }
    }
    
    func filterUserInfo(with keyValuePairs: [KeyValuePair]) -> [UNNotificationRequest] {
        return self.filter { request in
            let userInfo = request.content.userInfo
            for pair in keyValuePairs {
                guard let aValue = userInfo[pair.key] as? String, aValue == pair.value else {
                    return false
                }
            }
            
            return true
        }
    }
    
    func printTriggerDates() {
        for request in self {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                let date = Date.dateFromComponents(trigger.dateComponents)!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                print(dateFormatter.string(from: date))
            }
        }
        
    }
}

extension UNUserNotificationCenter {
    
    func addRequests(_ requests: [UNNotificationRequest], completionHandler: (() -> Void)? = nil) {
        let group = DispatchGroup()
        for request in requests {
            group.enter()
            
            add(request) { error in
                if let error = error {
                    debugPrint("Failed to add notification request: \(error.localizedDescription)")
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completionHandler?()
        }
    }
}

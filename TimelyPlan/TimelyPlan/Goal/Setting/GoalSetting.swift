//
//  GoalSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

class GoalSetting {
    
    enum Key: String, SettingKeyRepresentable {
        case sound /// 通知音
        
        static func keyPrefix() -> String? {
            return "GoalSetting"
        }
    }
    
    /// 通知音
    @CloudStored(key: Key.sound.name, defaultValue: nil)
    var sound: NotificationSound?
    
    static let shared = GoalSetting()
    
    private init() {}
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKeys keys: [Key]) {
        let names = keys.map { $0.name }
        KeyValueStorage.shared.addObserver(observer, forKeys: names)
    }
}

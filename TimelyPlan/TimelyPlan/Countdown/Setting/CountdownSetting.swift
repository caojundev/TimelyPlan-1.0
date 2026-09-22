//
//  CountdownSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/22.
//

import Foundation

class CountdownSetting {
    
    enum Key: String, SettingKeyRepresentable {
        case showInCalendar /// 在日历显示
        case showInMyDay    /// 在我的一天显示
        case sound          /// 通知声音
        
        static func keyPrefix() -> String? {
            return "CountdownSetting"
        }
    }
    
    /// 在日历显示
    @CloudStored(key: Key.showInCalendar.name, defaultValue: true)
    var showInCalendar: Bool
    
    /// 在我的一天显示
    @CloudStored(key: Key.showInMyDay.name, defaultValue: true)
    var showInMyDay: Bool
    
    /// 通知声音
    @CloudStored(key: Key.sound.name, defaultValue: nil)
    var sound: NotificationSound?
    
    static let shared = CountdownSetting()
    
    private init() {}
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKeys keys: [Key]? = nil) {
        let keys = keys ?? Key.allCases
        let keyNames = keys.map { $0.name }
        KeyValueStorage.shared.addObserver(observer, forKeys: keyNames)
    }
}

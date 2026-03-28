//
//  AppSetting.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/28.
//

import Foundation

class AppSetting {
    
    enum Key: String, SettingKeyRepresentable {
        case isHapiticFeedbackOn
        
        static func keyPrefix() -> String? {
            return "AppSetting"
        }
    }

    /// 震动反馈开关
    @CloudStored(key: Key.isHapiticFeedbackOn.name, defaultValue: false)
    var isHapiticFeedbackOn: Bool
    
    static let shared = AppSetting()
    
    private init() {}
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: Key) {
        KeyValueStorage.shared.addObserver(observer, forKey: key.name)
    }
}

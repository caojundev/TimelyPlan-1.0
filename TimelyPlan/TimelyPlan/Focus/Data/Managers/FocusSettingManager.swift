//
//  FocusSettingManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/12.
//

import Foundation

class FocusSettingManager {
    
    private var setting: FocusSetting?
    
    func getSetting() -> FocusSetting {
        if let setting = setting {
            return setting
        }
        
        /// 获取
        var setting: FocusSetting? = KeyValueStorage.shared.value(forKey: FocusSetting.keyName)
        if setting == nil {
            setting = FocusSetting()
        }
        
        self.setting = setting
        return self.setting!
    }
    
    func setSetting(_ setting: FocusSetting) {
        self.setting = setting
        KeyValueStorage.shared.setValue(setting, forKey: FocusSetting.keyName)
    }
    
}

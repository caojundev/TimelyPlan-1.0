//
//  StoragePropertyWrapper.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/24.
//

/// 本地存储属性包装器，用于自动持久化 Codable 类型的数据
@propertyWrapper
struct LocalStored<T: Codable> {
    /// 存储键名
    let key: String
    /// 默认值
    let defaultValue: T
    
    /// 包装值，提供自动的 getter 和 setter
    var wrappedValue: T {
        get {
            let value: T? = SettingAgent.shared.value(forKey: key)
            return value ?? defaultValue
        }
        
        set {
            SettingAgent.shared.setValue(newValue, forKey: key)
        }
    }
}

/// 云端存储属性包装器
@propertyWrapper
struct CloudStored<T: Codable> {
    /// 存储键名
    let key: String
    /// 默认值
    let defaultValue: T
    
    /// 包装值，提供自动的 getter 和 setter
    var wrappedValue: T {
        get {
            let value: T? = KeyValueStorage.shared.value(forKey: key)
            return value ?? defaultValue
        }

        set {
            KeyValueStorage.shared.setValue(newValue, forKey: key)
        }
    }
}


class ObservableLocalStore {
    
    func addObserver(_ observer: SettingAgentObserver, forKey name: String) {
        SettingAgent.shared.addObserver(observer, forKey: name)
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKeys names: [String]) {
        SettingAgent.shared.addObserver(observer, forKeys: names)
    }
}

class ObservableCloudStore {
    
    func addObserver(_ observer: SettingAgentObserver, forKey name: String) {
        KeyValueStorage.shared.addObserver(observer, forKey: name)
    }

    func addObserver(_ observer: SettingAgentObserver, forKeys names: [String]) {
        KeyValueStorage.shared.addObserver(observer, forKeys: names)
    }
}



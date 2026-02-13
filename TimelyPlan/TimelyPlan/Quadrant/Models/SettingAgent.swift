//
//  SettingAgent.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/11.
//

import Foundation

protocol SettingKeyRepresentable: RawRepresentable, CaseIterable {
    
    /// 键值前缀
    static func keyPrefix() -> String?
}

extension SettingKeyRepresentable where RawValue == String {
    
    static var allNames: [String] {
        return Self.allCases.map { $0.name }
    }

    var name: String {
        guard let prefix = Self.keyPrefix() else {
            return rawValue
        }
        
        return prefix + "." + rawValue
    }
    
    init?(name: String) {
        guard Self.keyPrefix() != nil else {
            self.init(rawValue: name)
            return
        }
        
        let components = name.components(separatedBy: ".")
        guard let rawValue = components.last else {
            return nil
        }
        
        self.init(rawValue: rawValue)
    }
}

// Define the protocol for observers
protocol SettingAgentObserver: AnyObject {
    func settingAgentDidChangeValue(for key: String)
}

class SettingAgent {
    
    /// 存储已获取数值字典
    private var valueDic: [String: Codable] = [:]
    
    private var observerMananger = SettingObserverManager()
    
    static let shared = SettingAgent()
    
    private init() {}
    
    func jsonString(forKey key: String) -> String? {
        return UserDefaults.standard.value(forKey: key) as? String
    }
    
    func setJsonString(_ json: String?, forKey key: String) {
        UserDefaults.standard.setValue(json, forKey: key)
    }
    
    func value<T: Codable>(forKey key: String, defaultValue: () -> T) -> T {
        if let value: T = value(forKey: key) {
            return value
        }
        
        let defaultValue = defaultValue()
        valueDic[key] = defaultValue
        return defaultValue
    }
    
    func value<T: Codable>(forKey key: String) -> T? {
        if let value = valueDic[key] as? T {
            return value
        }
        
        guard let stringValue = jsonString(forKey: key) else {
            return nil
        }
    
        if let _ = T.self as? String.Type {
            /// 对象类型为String类型时直接返回
            let result = stringValue as? T
            if let result = result {
                valueDic[key] = result
            }
            
            return result
        }
        
        /// 解析对象
        let result = T.model(with: stringValue)
        if let result = result {
            valueDic[key] = result
        }
        
        return result
    }
    
    func setValue(_ value: Codable?, forKey key: String, synchronizeImediately: Bool = false) {
        guard let value = value else {
            valueDic[key] = nil
            setJsonString(nil, forKey: key)
            if synchronizeImediately {
                synchronize()
            }
            
            return
        }

        valueDic[key] = value
        
        let newJsonString = value.jsonString()
        setJsonString(newJsonString, forKey: key)
        observerMananger.valueDidChange(forKey: key)
        
        if synchronizeImediately {
            synchronize()
        }
    }
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: String?) {
        observerMananger.addObserver(observer, forKey: key)
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKeys keys: [String]) {
        observerMananger.addObserver(observer, forKeys: keys)
    }
    
    func removeObserver(_ observer: SettingAgentObserver, forKey key: String?) {
        observerMananger.removeObserver(observer, forKey: key)
    }
    
    func removeObserver(_ observer: SettingAgentObserver, forKeys keys: [String]) {
        observerMananger.removeObserver(observer, forKeys: keys)
    }
    
    // MARK: - 同步数据
    func synchronize() {
        UserDefaults.standard.synchronize()
    }
}

class SettingObserverManager {
    
    // Use a dictionary to hold observers for specific keys
    private var observersForKeyDic: [String: NSHashTable<AnyObject>] = [:]
    
    // Use a hash table to hold observers for all keys
    private var observersForAllKeysTable: NSHashTable<AnyObject> = NSHashTable<AnyObject>.weakObjects()

    func valueDidChange(forKey key: String) {
        observersForKeyDic[key]?.allObjects.forEach { observer in
            (observer as? SettingAgentObserver)?.settingAgentDidChangeValue(for: key)
        }

        observersForAllKeysTable.allObjects.forEach { observer in
            (observer as? SettingAgentObserver)?.settingAgentDidChangeValue(for: key)
        }
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKeys keys: [String]) {
        for key in keys {
            addObserver(observer, forKey: key)
        }
    }

    func addObserver(_ observer: SettingAgentObserver, forKey key: String?) {
        guard let key = key, key.count > 0 else {
            addObserverForAllKeys(observer)
            return
        }

        if observersForKeyDic[key] == nil {
            observersForKeyDic[key] = NSHashTable<AnyObject>.weakObjects()
        }
        
        observersForKeyDic[key]?.add(observer)
    }

    func removeObserver(_ observer: SettingAgentObserver, forKeys keys: [String]) {
        for key in keys {
            removeObserver(observer, forKey: key)
        }
    }
    
    func removeObserver(_ observer: SettingAgentObserver, forKey key: String?) {
        guard let key = key, key.count > 0 else {
            removeObserverForAllKeys(observer)
            return
        }
  
        observersForKeyDic[key]?.remove(observer)
        if observersForKeyDic[key]?.count == 0 {
            observersForKeyDic.removeValue(forKey: key)
        }
    }

    func addObserverForAllKeys(_ observer: SettingAgentObserver) {
        observersForAllKeysTable.add(observer)
    }

    func removeObserverForAllKeys(_ observer: SettingAgentObserver) {
        observersForAllKeysTable.remove(observer)
    }
}

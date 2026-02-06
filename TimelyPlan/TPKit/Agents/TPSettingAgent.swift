//
//  TPSettingAgent.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/28.
//

import Foundation

// Define the protocol for observers
protocol TPSettingAgentObserver: AnyObject {
    func settingAgentDidChangeValue(for key: String)
}

class TPSettingAgent {
    
    // Use a dictionary to hold observers for specific keys
    private var observersForKeyDic: [String: NSHashTable<AnyObject>] = [:]
    
    // Use a hash table to hold observers for all keys
    private var observersForAllKeysTable: NSHashTable<AnyObject> = NSHashTable<AnyObject>.weakObjects()

    // Singleton instance
    static let shared = TPSettingAgent()

    // Prevent creating new instances
    private init() {
        observersForKeyDic = [:]
    }

    // Check if a key exists in UserDefaults
    func isKeyExist(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    /// Integer
    func integer(forKey defaultName: String) -> Int {
        return UserDefaults.standard.integer(forKey: defaultName)
    }
    
    func setInteger(_ value: Int, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
        valueDidChange(forKey: defaultName)
    }

    /// Double
    func double(forKey defaultName: String) -> Double {
        return UserDefaults.standard.double(forKey: defaultName)
    }
    
    func setDouble(_ value: Double, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
        valueDidChange(forKey: defaultName)
    }

    /// Bool
    func bool(forKey defaultName: String) -> Bool {
        return UserDefaults.standard.bool(forKey: defaultName)
    }

    func setBool(_ value: Bool, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
        valueDidChange(forKey: defaultName)
    }

    /// Dictionary
    func dictionaryForKey(_ key: String) -> [String: Any]? {
        return UserDefaults.standard.dictionary(forKey: key)
    }
    
    func setDictionary(_ dic: NSDictionary, forKey defaultName: String) {
        UserDefaults.standard.set(dic, forKey: defaultName)
        valueDidChange(forKey: defaultName)
    }

    /// Codable 对象
    func value<T: Decodable>(forKey defaultName: String) -> T? {
        guard let jsonString = UserDefaults.standard.string(forKey: defaultName) else {
            return nil
        }
        
        if let _ = T.self as? String.Type {
            /// 对象类型为String类型时直接返回
            return jsonString as? T
        }
        
        return T.model(with: jsonString)
    }
    
    func set(value: Encodable, forKey defaultName: String) {
        let jsonString = value.jsonString()
        UserDefaults.standard.set(jsonString, forKey: defaultName)
        valueDidChange(forKey: defaultName)
    }
    
    // MARK: - 同步数据
    func synchronize() {
        UserDefaults.standard.synchronize()
    }

    // MARK: - Observers
    private func valueDidChange(forKey key: String) {
        observersForKeyDic[key]?.allObjects.forEach { observer in
            (observer as? TPSettingAgentObserver)?.settingAgentDidChangeValue(for: key)
        }

        observersForAllKeysTable.allObjects.forEach { observer in
            (observer as? TPSettingAgentObserver)?.settingAgentDidChangeValue(for: key)
        }
    }

    func addObserver(_ observer: TPSettingAgentObserver, forKey key: String) {
        if key.isEmpty {
            addObserverForAllKeys(observer)
            return
        }

        if observersForKeyDic[key] == nil {
            observersForKeyDic[key] = NSHashTable<AnyObject>.weakObjects()
        }

        observersForKeyDic[key]?.add(observer)
    }

    func removeObserver(_ observer: TPSettingAgentObserver, forKey key: String) {
        if key.isEmpty {
            removeObserverForAllKeys(observer)
            return
        }

        observersForKeyDic[key]?.remove(observer)

        if observersForKeyDic[key]?.count == 0 {
            observersForKeyDic.removeValue(forKey: key)
        }
    }

    func addObserverForAllKeys(_ observer: TPSettingAgentObserver) {
        observersForAllKeysTable.add(observer)
    }

    func removeObserverForAllKeys(_ observer: TPSettingAgentObserver) {
        observersForAllKeysTable.remove(observer)
    }
}

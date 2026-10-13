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
    func settingAgentDidChangeValue(for keyName: String)
}

class SettingAgent {
    
    /// 存储已获取数值字典
    /// - Note: 主线程与后台线程会同时访问，必须加锁保护；并发读写非线程安全的
    ///         Swift Dictionary 会导致其内部存储被提前释放，读到已释放内存时会抛出
    ///         `unrecognized selector` 异常并崩溃。
    private var valueDic: [String: Codable] = [:]
    
    /// 保护 valueDic 的锁（仅用于纯内存读写，禁止在持锁期间做耗时操作）
    private let lock = NSLock()
    
    private var observerMananger = SettingObserverManager()
    
    static let shared = SettingAgent()
    
    private init() {}
    
    /// 读取缓存值（线程安全）
    private func cachedValue(forKey key: String) -> Codable? {
        lock.lock()
        defer { lock.unlock() }
        return valueDic[key]
    }
    
    /// 写入/移除缓存值（线程安全）
    private func setCachedValue(_ value: Codable?, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        valueDic[key] = value
    }
    
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
        setCachedValue(defaultValue, forKey: key)
        return defaultValue
    }
    
    func value<T: Codable>(forKey key: String) -> T? {
        let value = cachedValue(forKey: key)
        if value != nil, let result = value as? T {
            return result
        }
        
        guard let stringValue = jsonString(forKey: key) else {
            return nil
        }
    
        if let _ = T.self as? String.Type {
            /// 对象类型为String类型时直接返回
            let result = stringValue as? T
            if let result = result {
                setCachedValue(result, forKey: key)
            }
            
            return result
        }
        
        /// 解析对象
        let result = T.model(with: stringValue)
        if let result = result {
            setCachedValue(result, forKey: key)
        }
        
        return result
    }
    
    func setValue(_ value: Codable?, forKey key: String, synchronizeImediately: Bool = false) {
        guard let value = value else {
            setCachedValue(nil, forKey: key)
            setJsonString(nil, forKey: key)
            if synchronizeImediately {
                synchronize()
            }
            
            return
        }

        setCachedValue(value, forKey: key)
        
        let newJsonString = value.jsonString()
        setJsonString(newJsonString, forKey: key)
    
        if synchronizeImediately {
            synchronize()
        }
        
        // 推送到下一个RunLoop循环执行
        DispatchQueue.main.async {
            self.observerMananger.valueDidChange(forKey: key)
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
    
    /// 观察者注册与通知可能发生在不同线程，必须加锁保护
    private let lock = NSLock()
    
    func valueDidChange(forKey key: String) {
        lock.lock()
        let keyedObservers = observersForKeyDic[key]?.allObjects ?? []
        let allKeysObservers = observersForAllKeysTable.allObjects
        lock.unlock()
        
        /// 先取快照再回调，避免回调中增删观察者造成死锁
        keyedObservers.forEach { observer in
            (observer as? SettingAgentObserver)?.settingAgentDidChangeValue(for: key)
        }

        allKeysObservers.forEach { observer in
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
        
        lock.lock()
        defer { lock.unlock() }

        let table: NSHashTable<AnyObject>
        if let exist = observersForKeyDic[key] {
            table = exist
        } else {
            table = NSHashTable<AnyObject>.weakObjects()
            observersForKeyDic[key] = table
        }
        
        table.add(observer)
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
        
        lock.lock()
        defer { lock.unlock() }
  
        let table = observersForKeyDic[key]
        table?.remove(observer)
        if table?.count == 0 {
            observersForKeyDic.removeValue(forKey: key)
        }
    }

    func addObserverForAllKeys(_ observer: SettingAgentObserver) {
        lock.lock()
        defer { lock.unlock() }
        observersForAllKeysTable.add(observer)
    }

    func removeObserverForAllKeys(_ observer: SettingAgentObserver) {
        lock.lock()
        defer { lock.unlock() }
        observersForAllKeysTable.remove(observer)
    }
}

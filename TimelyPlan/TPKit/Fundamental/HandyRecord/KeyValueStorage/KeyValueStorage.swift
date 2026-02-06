//
//  KeyValueEntryManager.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/7.
//

import Foundation
import CoreData

class KeyValueStorage {

    static let shared = KeyValueStorage()
    
    /// 修改数据后是否立即同步
    var synchronizeImmediately = true
    
    /// 上下文
    private let context: NSManagedObjectContext
    
    /// 实体名称
    private let entityName: String = "KeyValueStore"
    
    /// 存储已获取数值字典
    private var valueDic: [String: Any] = [:]
    
    /// 根据上下文和实体名称初始化键值存储对象
    init() {
        self.context = .defaultContext
    }
    
    // MARK: - 对象
    func value<T: Decodable>(forName key: String, defaultValue: T) -> T {
        let value: T? = value(forKey: key)
        if let value = value {
            return value
        }
        
        valueDic[key] = defaultValue
        return defaultValue
    }
    
    func value<T: Decodable>(forKey key: String) -> T? {
        if let value = valueDic[key] as? T {
            return value
        }
        
        let store = store(forKey: key)
        guard let str = store?.value else { return nil }
        if let _ = T.self as? String.Type {
            /// 对象类型为String类型时直接返回
            let result = str as? T
            if let result = result {
                valueDic[key] = result
            }
            
            return result
        }
        
        /// 解析对象
        let result = T.model(with: str)
        if let result = result {
            valueDic[key] = result
        }
        
        return result
    }
    
    func setValue(_ value: Encodable, forKey key: String) {
        valueDic[key] = value
        if let entry = entry(forKey: key, createIfNil: true) {
            entry.value = value.jsonString()
        }
        
        if synchronizeImmediately {
            synchronize()
        }
    }
    
    // MARK: - 
    // 判断key是否存在
    func isKeyExist(_ key: String) -> Bool {
        if let _ = store(forKey: key) {
            return true
        }
        
        return false
    }
    
    // 进行保存操作
    func synchronize() {
        context.saveWithOptions([.parentContexts], completion: nil)
    }
    
    /// 移除key对应的值
    func removeValue(forKey key: String) {
        valueDic.removeValue(forKey: key)
        if let store = store(forKey: key) {
            context.delete(store)
        }
    }
    
    // MARK: - Helper
    fileprivate func store(forKey key: String) -> KeyValueEntry? {
        return entry(forKey: key, createIfNil: false)
    }
    
    /// 获取key对应的键值条目
    /// - Parameters:
    ///   - key: 键名称
    ///   - createIfNil: 如果值为空是否创建一个新值
    /// - Returns: 键值条目
    fileprivate func entry(forKey key: String, createIfNil: Bool) -> KeyValueEntry? {
        if let entries = entries(forKey: key), entries.count > 0 {
            return entries.first!
        }
        
        if createIfNil {
            let entry = KeyValueEntry.createEntity(forEntityName: entityName, in: context)
            entry.key = key
            return entry
        }
        
        return nil
    }
    
    /// 获取key对应的所有键值条目数组
    fileprivate func entries(forKey key: String) -> [KeyValueEntry]? {
        let request = NSFetchRequest<KeyValueEntry>(entityName: entityName)
        request.predicate = NSPredicate(format: "key == %@", key)
        let results: [KeyValueEntry]? = KeyValueEntry.executeFetchRequest(request, in: context)
        return results
    }
}

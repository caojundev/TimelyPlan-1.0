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
    private let entityName = EntityName.keyValueStore.rawValue
    
    /// 存储已获取数值字典
    /// - Note: 主线程（界面刷新）与后台线程（数据刷新、通知调度等）会同时访问，
    ///         必须加锁保护；否则并发读写非线程安全的 Swift Dictionary 会导致其内部
    ///         存储被提前释放，读到已释放内存时会抛出 `unrecognized selector` 异常并崩溃。
    private var valueDic: [String: Any] = [:]
    
    /// 保护 valueDic / observedRemoteKeys 的锁
    /// - Warning: 仅用于纯内存读写，禁止在持锁期间执行 CoreData 查询等耗时操作，
    ///            否则会与默认（主队列）上下文的 performAndWait 相互等待造成死锁。
    private let lock = NSLock()
    
    private var observerMananger = SettingObserverManager()
    
    /// 监听远程更新的键值
    private var observedRemoteKeys = Set<String>()

    func startObservingRemoteValue(forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        observedRemoteKeys.insert(key)
    }

    func stopObservingRemoteValue(forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        observedRemoteKeys.remove(key)
    }
    
    // MARK: - 缓存读写
    /// 读取缓存值（线程安全）
    private func cachedValue(forKey key: String) -> Any? {
        lock.lock()
        defer { lock.unlock() }
        return valueDic[key]
    }
    
    /// 写入/移除缓存值（线程安全）
    private func setCachedValue(_ value: Any?, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        if let value = value {
            valueDic[key] = value
        } else {
            valueDic.removeValue(forKey: key)
        }
    }
    
    // MARK: - 存储读取
    /// 存储中的条目（已脱离上下文，可在任意线程安全使用）
    private struct StoredEntry {
        let value: String?
    }
    
    /// 读取 key 在存储中的条目
    /// - Note:
    ///   - 主线程使用默认（主队列）上下文；
    ///   - 后台线程使用根保存（私有队列）上下文，查询只在该上下文自己的队列上等待，
    ///     不会同步到主队列；后台读取设置不再阻塞主线程，可避免线程堆在主队列上。
    private func storedEntry(forKey key: String) -> StoredEntry? {
        let targetContext = Thread.isMainThread ? context : NSManagedObjectContext.rootSavingContext
        
        var entry: StoredEntry?
        targetContext.performAndWait {
            let request = NSFetchRequest<KeyValueEntry>(entityName: entityName)
            request.predicate = NSPredicate(format: "key == %@", key)
            request.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]
            request.fetchLimit = 1
            
            /// 在上下文队列内把值取出为纯字符串，避免跨线程持有托管对象
            if let result = try? targetContext.fetch(request).first {
                entry = StoredEntry(value: result.value)
            }
        }
        return entry
    }
    
    /// 在主线程执行写入相关的持久化操作
    /// - Note: 已在主线程时直接执行；后台线程则异步投递到主队列，
    ///         避免后台线程同步等待主队列（等待主队列是线程堆积的根源之一），
    ///         也不会在后台线程违规操作主队列上下文。
    private func performPersistOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
    
    /// 根据上下文和实体名称初始化键值存储对象
    init() {
        self.context = .defaultContext
        HandyRecord.observeRemoteChange { [weak self] changeInfo in
            let entityNames = changeInfo.entityNames
            if entityNames.contains(.keyValueStore) {
                let results = changeInfo.extractKeyValueStore()
                self?.didChangeRemoteValue(with: results)
            }
        }
    }
    
    private func didChangeRemoteValue(with results: EntityChangeResults<KeyValueEntry>?) {
        guard let results = results else {
            return
        }
        
        let inserted = results.inserted.compactMap{ $0.key }
        let updated = results.updated.compactMap{ $0.key }
        let keys = inserted + updated
        
        lock.lock()
        let observedKeys = Set(keys).intersection(observedRemoteKeys)
        lock.unlock()
        
        DispatchQueue.main.async {
            for key in observedKeys {
                self.setCachedValue(nil, forKey: key)
                self.observerMananger.remoteValueDidChange(forKey: key)
            }
        }
    }
    
    // MARK: - 对象
    func value<T: Decodable>(forName key: String, defaultValue: T) -> T {
        let value: T? = value(forKey: key)
        if let value = value {
            return value
        }
        
        setCachedValue(defaultValue, forKey: key)
        return defaultValue
    }
    
    func value<T: Decodable>(forKey key: String) -> T? {
        let value = cachedValue(forKey: key)
        if value != nil, let result = value as? T {
            return result
        }
        
        guard let str = storedEntry(forKey: key)?.value else { return nil }
        if let _ = T.self as? String.Type {
            /// 对象类型为String类型时直接返回
            let result = str as? T
            if let result = result {
                setCachedValue(result, forKey: key)
            }
            
            return result
        }
        
        /// 解析对象
        let result = T.model(with: str)
        if let result = result {
            setCachedValue(result, forKey: key)
        }
        
        return result
    }
    
    func setValue(_ value: Encodable, forKey key: String) {
        /// 先同步更新内存缓存，保证「写后立即读」在任意线程都取到新值
        setCachedValue(value, forKey: key)
        
        performPersistOnMain {
            self.persist(value, forKey: key)
        }
    }
    
    /// 将键值写入存储（必须在主线程、使用默认上下文执行）
    private func persist(_ value: Encodable, forKey key: String) {
        var entry: KeyValueEntry
        if let entries = entries(forKey: key), entries.count > 0 {
            entry = entries[0]
            if entries.count > 1 {
                let deleteEntries = Array(entries.dropFirst(1))
                context.deleteObjects(deleteEntries)
            }
        } else {
            entry = KeyValueEntry.createEntity(forEntityName: entityName, in: context)
            entry.key = key
        }
        
        entry.value = value.jsonString()
        entry.modificationDate = .now
        
        if synchronizeImmediately {
            synchronize()
        }
        
        // 推送到下一个RunLoop循环执行
        DispatchQueue.main.async {
            self.observerMananger.valueDidChange(forKey: key)
        }
    }
    
    // MARK: - 
    // 判断key是否存在
    func isKeyExist(_ key: String) -> Bool {
        return storedEntry(forKey: key) != nil
    }
    
    // 进行保存操作
    func synchronize() {
        context.saveWithOptions([.parentContexts], completion: nil)
    }
    
    /// 移除key对应的值
    func removeValue(forKey key: String) {
        setCachedValue(nil, forKey: key)
        performPersistOnMain {
            if let store = self.store(forKey: key) {
                self.context.delete(store)
                self.observerMananger.valueDidChange(forKey: key)
            }
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
    
    // MARK: - Helper
    /// 获取key对应的键值条目
    /// - Warning: 返回的托管对象属于默认（主队列）上下文，仅供主线程的写入流程使用；
    ///            读取请使用 `storedEntry(forKey:)`
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
            return entries.first
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
        let sortDescriptor = NSSortDescriptor(key: "modificationDate", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let results: [KeyValueEntry]? = KeyValueEntry.executeFetchRequest(request, in: context)
        return results
    }
    
    /// 打印所有条目数据
    func printAllEntries() {
        let targetContext = Thread.isMainThread ? context : NSManagedObjectContext.rootSavingContext
        
        var lines = [String]()
        targetContext.performAndWait {
            let request = NSFetchRequest<KeyValueEntry>(entityName: entityName)
            guard let results = try? targetContext.fetch(request) else { return }
            
            /// 在上下文队列内取出打印文本，避免跨线程持有托管对象
            lines = results.map {
                "\($0.key ?? "") = \($0.value ?? ""), \($0.modificationDate?.yearMonthDayTimeString(omitYear: true) ?? "无日期")"
            }
        }
        
        lines.forEach { debugPrint($0) }
    }
}

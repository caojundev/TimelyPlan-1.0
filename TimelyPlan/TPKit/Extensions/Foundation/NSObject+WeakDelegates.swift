//
//  WeakDelegates.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/12.
//

import Foundation

protocol WeakDelegates: AnyObject {
    var weakDelegates: NSHashTable<AnyObject> { get set }
}

extension WeakDelegates {
    
    func addDelegates(_ delegates: [AnyObject]) {
        for delegate in delegates {
            addDelegate(delegate)
        }
    }
    
    func addDelegate(_ delegate: AnyObject) {
        /// 委托的增删与通知可能发生在不同线程（主线程、后台数据刷新、通知调度等），
        /// 必须加锁保护，否则 NSHashTable 并发访问会破坏内部结构导致非稳定崩溃
        let table = weakDelegates
        objc_sync_enter(table)
        defer { objc_sync_exit(table) }
        
        if !table.contains(delegate) {
            table.add(delegate)
        }
    }
    
    func removeDelegate(_ delegate: AnyObject) {
        let table = weakDelegates
        objc_sync_enter(table)
        defer { objc_sync_exit(table) }
        table.remove(delegate)
    }
    
    func removeAllDelegates() {
        let table = weakDelegates
        objc_sync_enter(table)
        defer { objc_sync_exit(table) }
        table.removeAllObjects()
    }
    
    /// 当前所有委托的快照（线程安全）
    func delegatesSnapshot() -> [AnyObject] {
        let table = weakDelegates
        objc_sync_enter(table)
        defer { objc_sync_exit(table) }
        return table.allObjects
    }
    
    func notifyDelegates<T>(_ callback: (T) -> Void) {
        /// 先取快照再回调，避免回调过程中增删委托导致的并发访问与死锁
        for delegate in delegatesSnapshot() {
            if let delegate = delegate as? T {
                callback(delegate)
            }
        }
    }
}

extension NSObject: WeakDelegates {
    
    private struct AssociatedKeys {
        static var delegatesKey = "delegatesKey"
    }
    
    var weakDelegates: NSHashTable<AnyObject> {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            
            if let hashTable = objc_getAssociatedObject(self, &AssociatedKeys.delegatesKey) as? NSHashTable<AnyObject> {
                return hashTable
            } else {
                let hashTable = NSHashTable<AnyObject>.weakObjects()
                objc_setAssociatedObject(self, &AssociatedKeys.delegatesKey, hashTable, .OBJC_ASSOCIATION_RETAIN)
                return hashTable
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.delegatesKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

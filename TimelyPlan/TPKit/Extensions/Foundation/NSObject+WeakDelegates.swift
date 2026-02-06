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
        if !weakDelegates.contains(delegate) {
            weakDelegates.add(delegate)
        }
    }
    
    func removeDelegate(_ delegate: AnyObject) {
        weakDelegates.remove(delegate)
    }
    
    func removeAllDelegates() {
        weakDelegates.removeAllObjects()
    }
    
    func notifyDelegates<T>(_ callback: (T) -> Void) {
        for delegate in weakDelegates.allObjects {
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
            if let hashTable = objc_getAssociatedObject(self, &AssociatedKeys.delegatesKey) as? NSHashTable<AnyObject> {
                return hashTable
            } else {
                let hashTable = NSHashTable<AnyObject>.weakObjects()
                objc_setAssociatedObject(self, &AssociatedKeys.delegatesKey, hashTable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return hashTable
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.delegatesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

//
//  TPWeakDelegateCollection.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/24.
//

import Foundation

class TPWeakDelegateCollection: WeakDelegates {
    
    var weakDelegates: NSHashTable<AnyObject>
    
    init() {
        self.weakDelegates = NSHashTable<AnyObject>.weakObjects()
    }
}

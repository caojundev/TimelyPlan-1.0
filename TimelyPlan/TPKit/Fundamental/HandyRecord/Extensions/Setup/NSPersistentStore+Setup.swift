//
//  NSPersistentStore+Setup.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

fileprivate var HandyRecordDefaultPersistentStore: NSPersistentStore?

extension NSPersistentStore {
    
    class var defaultPersistentStore: NSPersistentStore? {
        get {
            return HandyRecordDefaultPersistentStore
        }
        
        set {
            HandyRecordDefaultPersistentStore = newValue
        }
    }
}

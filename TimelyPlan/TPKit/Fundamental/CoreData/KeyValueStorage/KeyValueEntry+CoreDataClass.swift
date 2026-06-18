//
//  KeyValueEntry+CoreDataClass.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/8.
//
//

import Foundation
import CoreData

@objc(KeyValueEntry)
public class KeyValueEntry: NSManagedObject {
    
}

extension KeyValueEntry : Identifiable {
    @NSManaged public var key: String?
    @NSManaged public var value: String?
    @NSManaged public var modificationDate: Date?
}

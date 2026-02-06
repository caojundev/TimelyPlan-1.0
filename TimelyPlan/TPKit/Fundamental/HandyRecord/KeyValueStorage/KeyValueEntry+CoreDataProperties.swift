//
//  KeyValueEntry+CoreDataProperties.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/8.
//
//

import Foundation
import CoreData

extension KeyValueEntry {
    @NSManaged public var key: String?
    @NSManaged public var value: String?
}

extension KeyValueEntry : Identifiable {

}

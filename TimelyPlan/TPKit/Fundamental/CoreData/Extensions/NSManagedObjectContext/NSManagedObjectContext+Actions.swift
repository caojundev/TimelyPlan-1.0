//
//  NSManagedObjectContext+Actions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/18.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
   
    /// 删除集合中所有对象
    func deleteObjects(_ objects: [NSManagedObject]) {
        for object in objects {
            delete(object)
        }
    }
    
}

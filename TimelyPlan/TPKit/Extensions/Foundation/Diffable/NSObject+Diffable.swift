//
//  NSObject+Diffable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/5.
//

import Foundation

extension NSObject: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self.isEqual(object)
    }
}

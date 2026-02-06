//
//  NSString+Diffable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/5.
//

import Foundation

extension NSString {
    
    open override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let string = object as? String {
            return self.isEqual(to: string)
        }
        
        return self.isEqual(object)
    }
}

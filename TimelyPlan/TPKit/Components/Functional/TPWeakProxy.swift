//
//  TPWeakProxy.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/6.
//

import Foundation
import Foundation

class TPWeakProxy<T: AnyObject>: NSObject {
    
    weak var target: T?

    init(target: T?) {
        self.target = target
    }
}

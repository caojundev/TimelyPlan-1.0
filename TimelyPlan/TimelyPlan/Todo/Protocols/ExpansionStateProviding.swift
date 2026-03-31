//
//  ExpansionStateProviding.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/31.
//

import Foundation

protocol ExpansionStateProviding: AnyObject {
    
    /// 是否是展开的清单
    func isExpanded(_ item: Nestable) -> Bool
    
    func canSetExpended(_ isExpended: Bool, for item: Nestable) -> Bool
    
    func setExpended(_ isExpended: Bool, for item: Nestable)
}

extension ExpansionStateProviding {
    
    func canSetExpended(_ isExpended: Bool, for item: Nestable) -> Bool {
        return true
    }
}

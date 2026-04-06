//
//  ExpansionStateProviding.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/31.
//

import Foundation

protocol ExpansionStateProviding: AnyObject {
    
    /// 是否是展开的清单
    func isExpanded(_ item: Any) -> Bool
    
    func canSetExpended(_ isExpended: Bool, for item: Any) -> Bool
    
    func setExpended(_ isExpended: Bool, for item: Any)
}

extension ExpansionStateProviding {
    
    func canSetExpended(_ isExpended: Bool, for item: Any) -> Bool {
        return true
    }
}

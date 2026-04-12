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
    
    /// 展开清单所有父条目
    func expandAllParent(of item: Nestable, includeCurrent: Bool = true) {
        if includeCurrent {
            setExpended(true, for: item)
        }
        
        var parent = item.parentItem
        while parent != nil {
            setExpended(true, for: parent!)
            parent = parent?.parentItem
        }
    }
}

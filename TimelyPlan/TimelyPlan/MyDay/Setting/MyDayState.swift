//
//  MyDayState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/25.
//

import Foundation

class MyDayState {
    
    enum Key: String, SettingKeyRepresentable {
        case isAllDayExpanded /// 全天区块是否展开
        
        static func keyPrefix() -> String? {
            return "MyDayState"
        }
    }
    
    /// 全天区块是否展开
    @LocalStored(key: Key.isAllDayExpanded.name, defaultValue: false)
    var isAllDayExpanded: Bool
    
    static let shared = MyDayState()
    
    private init() {}
}

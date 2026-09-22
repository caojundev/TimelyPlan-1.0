//
//  CountdownState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/22.
//

import Foundation

class CountdownState {
    
    enum Key: String, SettingKeyRepresentable {
        case layoutType /// 布局类型
        
        static func keyPrefix() -> String? {
            return "CountdownState"
        }
    }
    
    /// 布局类型（默认为列表）
    @LocalStored(key: Key.layoutType.name, defaultValue: .list)
    var layoutType: CountdownLayoutType
    
    static let shared = CountdownState()
    
    private init() {}
}

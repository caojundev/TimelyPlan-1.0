//
//  ThemeKey.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/23.
//

import Foundation

struct ThemeKey: ExpressibleByStringLiteral {
    
    let value: String
    
    init(stringLiteral value: StringLiteralType) {
        self.value = value
    }
    
    init(value: String) {
        self.value = value
    }
}

extension ThemeKey {
    
    static func /(lhs: ThemeKey, rhs: ThemeKey) -> ThemeKey {
        return "\(lhs.value)/\(rhs.value)".themeKey
    }
    
    static func /=(lhs: inout ThemeKey, rhs: ThemeKey) {
        lhs = lhs / rhs
    }
}

extension Array where Element == ThemeKey {
    
    /// 主题键值
    var themeKey: ThemeKey {
        let value = self.map { $0.value }.joined(separator: "/")
        return ThemeKey(value: value)
    }
    
}

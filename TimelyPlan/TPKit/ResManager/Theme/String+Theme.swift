//
//  String+Theme.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/23.
//

import Foundation

extension String {
    
    /// 主题键值
    var themeKey: ThemeKey {
        return ThemeKey(value: self)
    }
    
    // 重载 / 运算符
    static func /(lhs: String, rhs: String) -> String {
        return "\(lhs)/\(rhs)"
    }
    
    static func /=(lhs: inout String, rhs: String) {
        lhs = lhs / rhs
    }
}

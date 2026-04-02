//
//  TodoEditingTag.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/25.
//

import Foundation

struct TodoEditingTag: Equatable {
    
    /// 名称
    var name: String?
    
    /// 颜色
    var color: UIColor = TodoTag.defaultColor
    
    // MARK: - Equatable
    static func == (lhs: TodoEditingTag, rhs: TodoEditingTag) -> Bool {
        return lhs.name == rhs.name && lhs.color.hexString == rhs.color.hexString
    }
}

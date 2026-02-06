//
//  TodoEditList.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/8.
//

import Foundation
import UIKit

struct TodoEditList: Equatable {
    
    /// 表情符号
    var emoji: String?
    
    /// 名称
    var name: String?
    
    /// 颜色
    var color: UIColor?
    
    /// 布局类型
    var layoutType: TodoListLayoutType = .list
    
    init(emoji: String? = nil,
         name: String? = nil,
         color: UIColor? = nil,
         layoutType: TodoListLayoutType = .list) {
        self.emoji = emoji
        self.name = name
        self.color = color
        self.layoutType = layoutType
    }
    
    // MARK: - Equatable
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.emoji == rhs.emoji &&
                lhs.name == rhs.name &&
                lhs.color == rhs.color &&
                lhs.layoutType == rhs.layoutType
    }
}

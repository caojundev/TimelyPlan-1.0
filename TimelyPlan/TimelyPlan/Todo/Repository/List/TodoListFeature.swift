//
//  TodoListFeature.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/8.
//

import Foundation
import UIKit

/// 列表特征信息
class TodoListFeature: NSObject,
                       TPHexColorConvertible,
                        TodoListRepresentable,
                        IdentifiableItem {

    /// 标识
    var identifier: String
  
    var emoji: String?
    
    /// 快照名称
    var name: String?
    
    /// 十六进制颜色字符串
    var colorHex: String?
    
    /// 布局类型原始数值
    var layoutRawValue: Int
    
    /// 显示名称
    var displayName: String {
        return name ?? resGetString("Untitled List")
    }
    
    /// 列表图标
    var icon: TPIcon? {
        if let emoji = emoji {
            return TPIcon(text: emoji)
        }
        
        let layoutType = TodoListLayoutType(rawValue: layoutRawValue) ?? .list
        return TPIcon(name: layoutType.miniIconName)
    }
    
    init(identifier: String,
         emoji: String?,
         name: String?,
         colorHex: String?,
         layoutRawValue: Int) {
        self.identifier = identifier
        self.emoji = emoji
        self.name = name
        self.colorHex = colorHex
        self.layoutRawValue = layoutRawValue
        super.init()
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoListFeature else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
}

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
  
    /// 快照名称
    var name: String?
    
    var displayName: String {
        return name ?? resGetString("Untitled List")
    }
    
    /// 十六进制颜色字符串
    var colorHex: String?
    
    init(identifier: String, name: String?, colorHex: String?) {
        self.identifier = identifier
        self.name = name
        self.colorHex = colorHex
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

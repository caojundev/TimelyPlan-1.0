//
//  TodoList.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

class TodoList: NSObject, Sortable, TPHexColorConvertible {

    /// 排序因子
    var order: Int64
    
    /// 任务唯一标识
    var identifier: String

    /// 颜色
    var colorHex: String?
    
    /// 表情符号
    var emoji: String?
    
    /// 名称
    var name: String?
    
    /// 布局
    var layoutType: TodoListLayoutType = .list
    
    /// 子列表
    var sublists: [TodoList]?
    
    /// 父清单
    weak var parent: TodoList?
    
    /// 是否收起
    var isCollapsed: Bool = false
  
    override init() {
        self.identifier = UUID().uuidString
        self.order = 0
        self.emoji = .randomEmoji()
        self.colorHex = UIColor.random.hexString
        self.name = "清单 \(arc4random() % 1000)"
        super.init()
    }
    
    
//    init(content: CDTodoList) {
//        self.identifier = content.identifier ?? UUID().uuidString
//        self.order = content.order
//        self.emoji = content.emoji
//        self.name = content.name
//        self.colorHex =  content.colorHex
//        self.layoutType = TodoListLayoutType(rawValue: Int(content.layoutRawValue)) ?? .list
//        super.init()
//    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(emoji)
        hasher.combine(name)
        hasher.combine(colorHex)
        hasher.combine(layoutType)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoList else { return false }
        if self === other { return true }
        return identifier == other.identifier &&
                emoji == other.emoji &&
                name == other.name &&
                colorHex == other.colorHex &&
                layoutType == other.layoutType
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
}

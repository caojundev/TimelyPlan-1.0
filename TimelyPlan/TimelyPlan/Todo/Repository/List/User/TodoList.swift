//
//  TodoList.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

/// 列表布局类型
enum TodoListLayoutType: Int, Codable, TPMenuRepresentable {
    
    case list
    case board
    
    static func titles() -> [String] {
        return ["List", "Board"]
    }

    var iconName: String? {
        switch self {
        case .list:
            return "todo_list_layout_list_96"
        case .board:
            return "todo_list_layout_board_96"
        }
    }
    
    var miniIconName: String {
        switch self {
        case .list:
            return "todo_list_24"
        case .board:
            return "todo_board_24"
        }
    }
}

class TodoList: NSObject,
                TodoListRepresentable,
                TPHexColorConvertible,
                IdentifiableItem,
                SortableIdentifiable {
    
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

    /// 父清单
    weak var parent: TodoList?
    
    /// 子列表
    var sublists: [TodoList]?

    /// 板块
    var sections: [TodoSection]?

    // MARK: - SortableIdentifiable
    /// 排序因子
    var order: Int64
    
    var identifiableKey: String {
        return identifier
    }
    
    init(content: CDTodoList) {
        self.identifier = content.identifier ?? UUID().uuidString
        self.order = content.order
        self.emoji = content.emoji
        self.name = content.name
        self.colorHex =  content.colorHex
        self.layoutType = TodoListLayoutType(rawValue: Int(content.layoutRawValue)) ?? .list
        super.init()
        self.sublists = content.sortedSublists(parent: self)
        self.sections = content.orderedSections(list: self)
    }
    
    func update(with editingList: TodoEditingList) {
        self.emoji = editingList.emoji
        self.name = editingList.name
        self.colorHex = editingList.color?.hexString
        self.layoutType = editingList.layoutType
    }
    
    func addSublist(_ list: TodoList) {
        if self.identifier == list.identifier {
            /// 列表不能作为自己的子列表
            return
        }
        
        if let parent = list.parent {
            /// 从原父清单移出
            parent.removeSublist(list)
        }
        
        var sublists = self.sublists ?? []
        sublists.append(list)
        self.sublists = sublists
        list.parent = self
    }
    
    func removeSublist(_ list: TodoList) {
        if let _ = sublists?.remove(list) {
            list.parent = nil
        }
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
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
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? TodoList else { return false }
        return identifier == other.identifier
    }

    // MARK: - 板块
    // 所有板块，包含无板块
    var allSections: [TodoSection] {
        var results = sections ?? []
        let noneSection = TodoSection.none(for: self)
        results.append(noneSection)
        return results
    }
    
    /// 显示名称
    var displayName: String {
        return name ?? resGetString("Untitled List")
    }

}

//
//  TodoList+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

extension TodoList {
    
    /// 列表图标
    var icon: TPIcon? {
        if let emoji = emoji {
            return TPIcon(text: emoji)
        }
        
        return TPIcon(name: layoutType.miniIconName)
    }
    
    var feature: TodoListFeature {
        return TodoListFeature(identifier: identifier,
                               name: name,
                               colorHex: colorHex)
    }
    
    // MARK: - 编辑列表
    
    /// 获取编辑列表
    var editingList: TodoEditingList {
        let list = TodoEditingList(emoji: emoji,
                                   name: name,
                                   color: color,
                                   layoutType: layoutType)
        return list
    }
    
    func isSameEditingList(as other: TodoEditingList) -> Bool {
        return editingList == other
    }
}

// MARK: - Nestable
extension TodoList: Nestable {
    
    static var allowMaxDepth: Int {
        return kTodoListMaxDepth
    }
    
    var parentItem: Nestable? {
        return self.parent
    }
    
    var subItems: [Nestable]? {
        return self.sublists
    }
    
    var orderedSubItems: [Nestable]? {
        return self.sublists?.orderedElements()
    }
}

extension Array where Element == TodoList {
    
    /// 获取顶层列表
    var topLists: [TodoList] {
        var lists = [TodoList]()
        for list in self {
            if list.parent == nil {
                lists.append(list)
            }
        }
        
        return lists
    }
}

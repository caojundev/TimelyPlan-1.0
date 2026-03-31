//
//  Nestable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/23.
//

import Foundation

protocol Nestable: NSObjectProtocol, Sortable {
    
    /// 父条目
    var parentItem: Nestable? { get }
    
    /// 子条目数组
    var subItems: [Nestable]? { get }
    
    /// 允许的最大深度
    static var allowMaxDepth: Int { get }
    
    // MARK: - 可选
    
    /// 列表深度，根列表为 0
    var depth: Int { get }
    
}

extension Nestable {
    
    /// 条目深度
    var depth: Int {
        var result: Int = 0
        var parent = self.parentItem
        while parent != nil {
            result += 1
            parent = parent?.parentItem
        }
        
        return result
    }
    
    /// 是否是根条目
    var isRootItem: Bool {
        return self.parentItem == nil
    }

    /// 父条目最大深度
    static func parentMaxDepth(for item: Nestable?) -> Int {
        let allowMaxDepth = Self.allowMaxDepth
        guard let item = item else {
            return allowMaxDepth - 1
        }

        return allowMaxDepth - item.maxLevel
    }
    
    var parentMaxDepth: Int {
        return Self.parentMaxDepth(for: self)
    }

    /// 当前条目下的最大层级数
    var maxLevel: Int {
        guard let subItems = subItems, subItems.count > 0 else {
            /// 如果当前列表没有子列表，则层级为1
            return 1
        }
        
        /// 遍历子条目，找出最大的层级数
        var maxLevel = 0
        for subItem in subItems {
            let subItemDepth = subItem.depth
            let maxSubItemLevel = Self.allowMaxDepth - subItemDepth + 1
            let subItemMaxLevel = min(subItem.maxLevel, maxSubItemLevel)
            if subItemMaxLevel > maxLevel {
                maxLevel = subItemMaxLevel
            }
        }
        
        // 当前层级数为子列表最大层级数加1
        return maxLevel + 1
    }
    
    /// 判断当前条目是否可以作为另一个条目的父条目
    func canBeParent(of item: Nestable) -> Bool {
        let total = self.depth + item.maxLevel
        return total <= Self.allowMaxDepth
    }

    // MARK: - 子条目
    /// 是否有子条目
    var hasSubItem: Bool {
        guard let subItems = self.subItems, subItems.count > 0 else {
            return false
        }
        
        return true
    }
    
    /// 顺序的子条目数组
    var orderedSubItems: [Nestable]? {
        if let orderedItems = subItems?.orderedElements() {
            return orderedItems
        }
        
        return []
    }
    
    /// 所有嵌套子条目顺序数组
    func flattenOrderedSubItems(with stateProvier: ExpansionStateProviding) -> [Nestable] {
        guard self.depth < Self.allowMaxDepth, let subItems = orderedSubItems, subItems.count > 0 else {
            return []
        }
        
        var result: [Nestable] = []
        for item in subItems {
            result.append(item)
            let isExpanded = stateProvier.isExpanded(item)
            if isExpanded {
                /// 列表展开
                result += item.flattenOrderedSubItems(with: stateProvier)
            }
        }
        
        return result
    }
    
    /// 返回子清单集合
    func allSubItems(with stateProvier: ExpansionStateProviding) -> [Nestable] {
        guard self.depth < Self.allowMaxDepth, let subItems = subItems, subItems.count > 0 else {
            return []
        }

        var result: [Nestable] = []
        for item in subItems {
            result.append(item)
            let isExpanded = stateProvier.isExpanded(item)
            if isExpanded {
                result += item.allSubItems(with: stateProvier)
            }
        }
        
        return result
    }

    /// 强制沾卡获取所有子条目
    func allSubItems() -> [Nestable] {
        guard self.depth < Self.allowMaxDepth, let subItems = subItems, subItems.count > 0 else {
            return []
        }

        var result: [Nestable] = []
        for item in subItems {
            result.append(item)
            result += item.allSubItems()
        }
        
        return result
    }
    
    /// 所有子条目数目
    var allSubItemsCount: Int {
        guard let subItems = self.subItems, subItems.count > 0 else {
            return 0
        }
        
        var count: Int = subItems.count
        for subItem in subItems {
            count += subItem.allSubItemsCount
        }
        
        return count
    }
    
    // MARK: - 获取移动后所影响的条目
    /// 获取移动列表需要更新的所有列表数组
    static func affectedItems<T: Nestable&Equatable>(for movedItems: [T], fromParent: T?) -> [T] {
        var results = [T]()
        for movedItem in movedItems {
            let items = Self.affectedItems(for: movedItem, fromParent: fromParent)
            results.append(contentsOf: items)
        }

        return results
    }
    
    static func affectedItems<T: Nestable&Equatable>(for movedItem: T, fromParent: T?) -> [T] {
        var results: [T] = [movedItem]
        var fromDepth: Int?
        if let fromParent = fromParent {
            fromDepth = fromParent.depth
            results.append(fromParent)
        }

        var toDepth: Int?
        if let toParent = movedItem.parentItem as? T, toParent != fromParent {
            toDepth = toParent.depth
            results.append(toParent)
        }

        // If the depths are different, add all sublists of the moved list
        if fromDepth != toDepth {
            let items = movedItem.allSubItems() as! [T]
            results.append(contentsOf: items)
        }

        return results
    }
    
}

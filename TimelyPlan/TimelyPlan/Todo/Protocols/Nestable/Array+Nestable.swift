//
//  Array+Nestable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/23.
//

import Foundation
import CoreGraphics

extension Array where Element: Nestable & Equatable {
    
    // MARK: - 获取列表
    /// 获取嵌套子清单顺序数组
    /// - Parameters:
    ///     - shouldExpand: 是否展开清单
    /// - Returns: 清单顺序数组
    func flattenItems(with stateProvier: ExpansionStateProviding) -> [Nestable] {
        var results: [Nestable] = []
        let rootItems = self
        for rootItem in rootItems {
            results.append(rootItem)
            let isExpanded = stateProvier.isExpanded(rootItem)
            if isExpanded {
                let subItems = rootItem.flattenOrderedSubItems(with: stateProvier)
                results.append(contentsOf: subItems)
            }
        }
        
        return results
    }
    
    // MARK: - 排序相关
    /// 获取插入索引处上下列表深度元组
    func depthRange(to targetIndex: Int, from sourceIndex: Int) -> (previous: Int, next: Int) {
        var prevDepth: Int = 0
        var nextDepth: Int = 0
        if targetIndex > sourceIndex {
            prevDepth = self[targetIndex].depth
            let nextRow = targetIndex + 1
            if nextRow < self.count {
                nextDepth = self[nextRow].depth
            }
        } else {
            let prevRow = targetIndex - 1
            if prevRow >= 0 {
                prevDepth = self[prevRow].depth
            } else {
                prevDepth = -1 /// 无上一行，深度设置为-1
            }

            var nextRow = targetIndex
            if targetIndex == sourceIndex {
                nextRow = targetIndex + 1
            }
            
            if nextRow < self.count {
                nextDepth = self[nextRow].depth
            }
        }
        
        return (prevDepth, nextDepth)
    }
    
    /// 获取插入缩进层级
    func indentationLevel(to targetIndex: Int, from sourceIndex: Int, ratio: CGFloat) -> Int {
        let range = depthRange(to: targetIndex, from: sourceIndex)
        var level: Int
        if range.previous < range.next {
            level = range.next
        } else {
            /// 最大层级
            let maxLevel = Element.allowMaxDepth - self[sourceIndex].maxLevel + 1
            let fromLevel = Swift.min(range.next, maxLevel)
            let toLevel = Swift.min(range.previous + 1, maxLevel)
            level = Int(ratio * Double(toLevel - fromLevel + 1)) + fromLevel
            level = Swift.min(Swift.max(fromLevel, level), toLevel)
        }
        
        return level
    }
    
    /// 获取专注位置索引
    func focusIndex(to targetIndex: Int, from sourceIndex: Int, depth: Int) -> Int? {
        var lists = self
        lists.moveObject(fromIndex: sourceIndex, toIndex: targetIndex)
        guard lists.count > 1 else {
            return nil
        }
    
        var parentItem: Nestable? = nil
        let aboveItems = lists.elementsAbove(at: targetIndex)
        for item in aboveItems {
            if item.depth < depth {
                parentItem = item
                break
            }
        }
        
        guard let parentItem = parentItem else {
            return nil
        }
        
        /// 返回父条目索引
        return self.firstIndex { item in
            return item === parentItem
        }
    }
    
    /// 判断是否可以将索引处的清单移进目标索引处清单中
    func canMoveItem(at index: Int, intoItemAt targetIndex: Int) -> Bool {
        let fromItem = self[index]
        let toItem = self[targetIndex]
        return toItem.canBeParent(of: fromItem)
    }
    
    /// 是否可以将索引处的列表插入到目标位置处
    func canInsertItem(at index: Int, to targetIndex: Int) -> Bool {
        let item = self[index]
        let itemLevel = item.maxLevel
        let range = depthRange(to: targetIndex, from: index)
        let depth = range.next + (itemLevel - 1)
        return depth <= Element.allowMaxDepth
    }
    
    /// 排序
    /*
    func reorderItem(fromIndex: Int, toIndex: Int, depth: Int) {
        var items = self
        items.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        
        guard items.count > 1 else { return }
        let currentItem = items[toIndex]
        var sameDepthItems = [currentItem]
        var parentItem: Nestable?
        let aboveItems = items.elementsAbove(at: toIndex)
        for aboveItem in aboveItems {
            let itemDepth = aboveItem.depth
            if itemDepth == depth {
                sameDepthItems.insert(aboveItem, at: 0)
            } else if itemDepth < depth {
                parentItem = aboveItem
                break
            }
        }
        
        /// 下方条目
        let belowItems = items.elementsBelow(at: toIndex)
        for belowItem in belowItems {
            let itemDepth = belowItem.depth
            if itemDepth == depth {
                sameDepthItems.append(belowItem)
            } else if itemDepth < depth {
                break
            }
        }
        
        let currentParent = currentItem.parentItem
        if let parentItem = parentItem {
            if !(parentItem.isEqual(currentParent)) {
                /// 非相同父列表，移动到当前父条目
                parentItem.addSubItem(currentItem)
                parentItem.isExpanded = true /// 展开当前父列表
            }
        } else {
            currentParent?.removeSubItem(currentItem)
        }
   
        /// 更新排序因子
        if sameDepthItems.count > 1 {
            sameDepthItems.updateOrders()
        }
    }
    */
}

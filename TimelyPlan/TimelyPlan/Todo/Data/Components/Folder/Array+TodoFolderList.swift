//
//  Array+TodoFolderList.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/12.
//

import Foundation

extension Array where Element: ListDiffable {
    
    enum ElementType {
        case folder
        case list
    }

    /// 索引处条目类型
    func elementType(at index: Int) -> ElementType {
        let item = self[index]
        if item is TodoFolder {
            return .folder
        }

        return .list
    }
    
    /// 获取索引所在处条目深度
    func depthForItem(at index: Int) -> Int {
        let item = self[index]
        guard let list = item as? TodoList else {
            return 0
        }
        
        if list.folder != nil {
            return 1
        }
        
        return 0
    }

    /// 获取插入索引处上下深度信息元组
    typealias DepthInfo = (type: ElementType?, depth: Int)
    
    func depthInfoRange(to targetIndex: Int, from sourceIndex: Int) -> (prev: DepthInfo, next: DepthInfo) {
        var prevDepth: Int = 0
        var prevType: ElementType? = nil
        var nextDepth: Int = 0
        var nextType: ElementType? = nil
        if targetIndex > sourceIndex {
            prevDepth = depthForItem(at: targetIndex)
            prevType = elementType(at: targetIndex)
            let nextRow = targetIndex + 1
            if nextRow < self.count {
                nextDepth = depthForItem(at: nextRow)
                nextType = elementType(at: nextRow)
            }
        } else {
            let prevRow = targetIndex - 1
            if prevRow >= 0 {
                prevDepth = depthForItem(at: prevRow)
                prevType = elementType(at: prevRow)
            } else {
                prevDepth = -1 /// 无上一行，深度设置为-1
            }

            var nextRow = targetIndex
            if targetIndex == sourceIndex {
                nextRow = targetIndex + 1
            }
            
            if nextRow < self.count {
                nextDepth = depthForItem(at: nextRow)
                nextType = elementType(at: nextRow)
            }
        }
        
        return ((prevType, prevDepth), (nextType, nextDepth))
    }
    
    /// 获取插入缩进层级
    func indentationLevel(to targetIndex: Int, from sourceIndex: Int, ratio: CGFloat) -> Int {
        let sourceElement = self[sourceIndex]
        if sourceElement is TodoFolder {
            /// 目录深度为 0
            return 0
        }
        
        let range = depthInfoRange(to: targetIndex, from: sourceIndex)
        if range.prev.depth < range.next.depth {
            return range.next.depth
        }
        
        let fromLevel = range.next.depth
        var toLevel = range.prev.depth
        if let type = range.prev.type, type == .folder {
            /// 上一个元素为目录
            toLevel += 1
        }
        
        var level = Int(ratio * Double(toLevel - fromLevel + 1)) + fromLevel
        clampValue(&level, fromLevel, toLevel)
        return level
    }
    
    /// 判断是否可以将索引处的条目移进目标索引处条目中
    func canMoveItem(at index: Int, intoItemAt targetIndex: Int) -> Bool {
        let fromItem = self[index]
        guard fromItem is TodoList else {
            return false
        }
    
        let toItem = self[targetIndex]
        guard toItem is TodoFolder else {
            return false
        }
        
        /// 可将清单移进目录中
        return true
    }
    
    /// 是否可以将索引处的列表插入到目标位置处
    func canInsertItem(at index: Int, to targetIndex: Int) -> Bool {
        if elementType(at: index) == .list {
            return true
        }
        
        let range = depthInfoRange(to: targetIndex, from: index)
        if range.prev.depth == 1, range.prev.depth == range.next.depth {
            return false
        }
    
        if let prevType = range.prev.type, prevType == .folder, range.next.depth == 1 {
            return false
        }
        
        return true
    }
    
    /// 获取专注位置索引
    func focusIndex(to targetIndex: Int, from sourceIndex: Int, depth: Int) -> Int? {
        guard let folder = moveFolder(to: targetIndex, from: sourceIndex, depth: depth) else {
            return nil
        }
        
        return indexOf(folder)
    }
    
    func moveFolder(to targetIndex: Int, from sourceIndex: Int, depth: Int) -> Element? {
        guard depth == 1, elementType(at: sourceIndex) == .list else {
            return nil
        }
        
        var items = self
        items.moveObject(fromIndex: sourceIndex, toIndex: targetIndex)
        guard targetIndex > 0 else {
            return nil
        }
        
        for i in stride(from: targetIndex - 1, through: 0, by: -1) {
            let item = items[i]
            if item is TodoFolder {
                return item
            }
        }

        return nil
    }
}

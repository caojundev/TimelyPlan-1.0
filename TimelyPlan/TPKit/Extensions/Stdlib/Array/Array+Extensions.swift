//
//  Array+Extension.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/4.
//

import Foundation

extension Array {
    
    /// 移动对象从 fromIndex 索引处到 toIndex 索引处
    mutating func moveObject(fromIndex:Int, toIndex:Int) {
        if fromIndex >= self.count || toIndex >= self.count {
            return
        }
        
        let obj = self[fromIndex]
        self.remove(at: fromIndex)
        self.insert(obj, at: toIndex)
    }
    
    mutating func replaceElement(at index: Int, with newElement: Element) {
        self.remove(at: index)
        self.insert(newElement, at: index)
    }
    
    mutating func removeElementsAtIndexes(indexes: IndexSet) {
       var offset = 0
       for index in indexes {
           let adjustedIndex = index - offset
           if adjustedIndex >= 0 && adjustedIndex < count {
               remove(at: adjustedIndex)
               offset += 1
           }
       }
    }
    
    func elementsAtIndexes(indexes: IndexSet) -> [Element] {
        var objects: [Element] = []
        for index in indexes {
            if index < count {
                objects.append(self[index])
            }
        }
        return objects
    }
    
    /// 返回随机元素
    func randomElement() -> Element? {
        guard !isEmpty else {
            return nil
        }
        
        let randomIndex = Int.random(in: 0..<count)
        return self[randomIndex]
    }
}

extension Array where Element: Equatable {
    
    /// 删除数组中特定元素，删除成功则返回删除元素索引
    @discardableResult
    mutating func remove(_ element: Element) -> Int? {
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
            return index
        }
        
        return nil
    }
    
    mutating func removeElements(from otherArray: [Element]) {
        self = self.filter { !otherArray.contains($0) }
    }
}

extension Array where Element: NSObject {
    
    static func == (lhs: [Element], rhs: [Element]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for i in 0..<lhs.count {
            if !lhs[i].isEqual(rhs[i]) {
                return false
            }
        }
        
        return true
    }
}

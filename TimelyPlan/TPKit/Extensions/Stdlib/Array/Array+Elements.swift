//
//  Array+Elements.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/5.
//

import Foundation

extension Array {
    
    /// 获取索引上方所有元素数组
    func elementsAbove(at index: Int) -> [Element] {
        guard index > 0 && index < self.count else {
            return []
        }
        
        var result: [Element] = []
        for i in stride(from: index - 1, through: 0, by: -1) {
            result.append(self[i])
        }
        
        return result
    }
        
    /// 获取索引下方所有元素数组
    func elementsBelow(at index: Int) -> [Element] {
        guard index >= 0 && index < self.count else {
            return []
        }
        
        return Array(self[(index + 1)..<self.count])
    }
}

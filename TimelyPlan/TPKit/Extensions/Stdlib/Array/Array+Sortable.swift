//
//  Ordered.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/11.
//

import Foundation
import UIKit

let ElementOrderKey = "order"

extension NSSet {
    
    func orderedElements() -> [Any]? {
        let sortDescriptor = NSSortDescriptor(key: ElementOrderKey, ascending: true)
        let elements = sortedArray(using: [sortDescriptor])
        return elements
    }
}

extension Set where Element: Sortable {
    
    var minOrder: Int64 {
        return self.min { $0.order < $1.order }?.order ?? 0
    }
    
    var maxOrder: Int64 {
        return self.max { $0.order < $1.order }?.order ?? 0
    }
    
    func orderedElements(ascending: Bool = true) -> [Element] {
        let elements = self.sorted {
            if ascending {
                return $0.order < $1.order
            } else {
                return $0.order > $1.order
            }
        }
        
        return elements
    }
}

let kOrderedStep: Int64 = 1024 /// 排序因子步长

extension Array {
    
    var minOrder: Int64 {
        guard let array = self as? [Sortable] else {
            return 0
        }
        
        return array.min { $0.order < $1.order }?.order ?? 0
    }
    
    var maxOrder: Int64 {
        guard let array = self as? [Sortable] else {
            return 0
        }
        
        return array.max { $0.order < $1.order }?.order ?? 0
    }
    
    /// 获取插入数组的排序因子
    func insertOrder(onTop: Bool = false) -> Int64 {
        let order: Int64
        if onTop {
            order = minOrder - kOrderedStep
        } else {
            order = maxOrder + kOrderedStep
        }
        
        return order
    }
    
    func updateOrders(){
        guard let array = self as? [Sortable] else {
            return
        }
        
        Self.updateOrder(for: array)
    }
    
    /// 返回根据 order 排序的元素数组
    func orderedElements(ascending: Bool = true) -> [Element] {
        guard let array = self as? [Sortable] else {
            return self
        }
                
        let elements = array.sorted {
            if ascending {
                return $0.order < $1.order
            } else {
                return $0.order > $1.order
            }
        }
        
        return elements as! [Element]
    }
    
    static func updateOrder(for elements: [Sortable]) {
        for index in 0 ..< elements.count{
            var previousOrder: Int64 = 0
            if index > 0 {
                previousOrder = elements[index - 1].order
            }
            
            var element = elements[index]
            let currentOrder = element.order
            
            var nextElement : Sortable?
            let nextIndex = index + 1
            if nextIndex < elements.count {
                nextElement = elements[nextIndex]
            }
            
            if previousOrder >= currentOrder {
                if let nextElement = nextElement, previousOrder + 1 < nextElement.order{
                    element.order = (previousOrder + nextElement.order) / 2
                } else {
                    element.order = ((previousOrder / kOrderedStep) + 1) * kOrderedStep
                }
                
                continue
            }
            
            guard let nextElement = nextElement else {
                break /// 无下一个条目，结束循环
            }
            
            let nextOrder = nextElement.order
            if currentOrder < nextOrder{
                continue /// 满足条件，进入下一轮
            }

            /// previousOrder < currentOrder > nextOrder
            if previousOrder + 1 < nextOrder {
                /// 取中间值
                element.order = (previousOrder + nextOrder) / 2
            }else{
                element.order = ((previousOrder / kOrderedStep) + 1) * kOrderedStep
            }
        }
    }
}

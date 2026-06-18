//
//  NSManagedObject+Sort.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/1.
//

import Foundation
import CoreData

// MARK: - 常量定义

/// 用于标识符属性的键名
let kIdentifierKeyName = "identifier"

// MARK: - 可排序标识协议

/// 支持排序和标识符查找的协议
/// 继承自 Sortable 协议，添加标识符功能
protocol SortableIdentifiable: Sortable {
    
    /// 用于查找和匹配的唯一标识键
    var identifiableKey: String { get }
}

// MARK: - NSManagedObject 扩展 - 标识符查询与排序同步

extension NSManagedObject {
    
    // MARK: 单对象查询
    
    /// 根据标识符获取单个托管对象
    /// - Parameter identifier: 对象的唯一标识符
    /// - Returns: 匹配的托管对象，未找到则返回 nil
    static func getItem(with identifier: String) -> Self? {
        let condition: PredicateCondition = (kIdentifierKeyName, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        return getFirst(matching: predicate, in: .defaultContext)
    }
    
    // MARK: 批量查询
    
    /// 根据标识符数组批量获取托管对象
    /// - Parameter identifiers: 对象标识符数组
    /// - Returns: 匹配的托管对象数组，未找到任何对象时返回 nil
    static func getItems(with identifiers: [String]) -> [NSManagedObject]? {
        let condition: PredicateCondition = (kIdentifierKeyName, .belongsTo(identifiers))
        let predicate = NSPredicate.predicate(with: condition)
        let results: [NSManagedObject]? = getAll(matching: predicate, in: .defaultContext)
        return results
    }
    
    /// 根据可排序标识对象数组获取对应的托管对象
    /// 提取数组中的标识符后进行批量查询
    /// - Parameter items: 遵循 SortableIdentifiable 协议的对象数组
    /// - Returns: 匹配的托管对象数组，未找到任何对象时返回 nil
    static func getIdentifiableItems(with items: [SortableIdentifiable]) -> [NSManagedObject]? {
        let identifiers = items.map { $0.identifiableKey }
        return getItems(with: identifiers)
    }
    
    // MARK: 排序同步操作
    
    /// 同步排序顺序到 Core Data 托管对象
    /// 将内存中对象的排序信息批量更新到持久化存储
    /// - Parameter items: 包含最新排序信息且遵循 SortableIdentifiable 协议的对象数组
    /// - Returns: 同步是否成功，未找到对应托管对象时返回 false
    @discardableResult
    static func syncOrders(for items: [SortableIdentifiable]) -> Bool {
        // 获取对应的托管对象
        guard let cdItems = getIdentifiableItems(with: items) else {
            return false
        }
        
        // 更新源对象的排序值
        items.updateOrders()
        
        // 执行排序同步
        syncOrders(from: items, to: cdItems)
        return true
    }
    
    // MARK: 私有方法
    
    /// 将源对象的排序信息同步到目标托管对象
    /// - Parameters:
    ///   - items: 包含最新排序信息的源对象数组
    ///   - cdItems: 需要更新排序信息的目标托管对象数组
    private static func syncOrders(from items: [SortableIdentifiable], to cdItems: [NSManagedObject]) {
        // 构建标识符到排序值的查找字典，提高查询效率
        let orderLookup = items.reduce(into: [String: Int64]()) { result, item in
            result[item.identifiableKey] = item.order
        }
        
        // 遍历所有托管对象，更新匹配的排序值
        cdItems.forEach { cdItem in
            if var item = cdItem as? SortableIdentifiable,
               let order = orderLookup[item.identifiableKey] {
                item.order = order
            }
        }
    }
}

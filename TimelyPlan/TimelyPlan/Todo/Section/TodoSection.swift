//
//  TodoSection.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/3.
//

import Foundation

class TodoSection: NSObject, SortableIdentifiable {
    
    var identifier: String
    
    /// 名称
    var name: String?
    
    /// 排序因子
    var order: Int64
    
    init(content: CDTodoSection) {
        self.identifier = content.identifier ?? ""
        self.name = content.name
        self.order = content.order
        super.init()
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoSection else { return false }
        if self === other { return true }
        return identifier == other.identifier &&
                name == other.name
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        return self.identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? TodoSection else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return identifier
    }
}

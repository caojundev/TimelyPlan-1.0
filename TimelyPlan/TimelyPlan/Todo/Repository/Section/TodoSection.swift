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
    
    /// 所属列表
    weak var list: TodoList?
    
    /// 特征值
    var feature: TodoSectionFeature {
        return TodoSectionFeature(identifier: identifier,
                                  name: name,
                                  order: order,
                                  list: list?.feature)
    }
    
    convenience init(content: CDTodoSection) {
        self.init(identifier: content.identifier ?? "",
                  name: content.name,
                  order: content.order)
    }
    
    init(identifier: String, name: String?, order: Int64) {
        self.identifier = identifier
        self.name = name
        self.order = order
        super.init()
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(list)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoSection else { return false }
        if self === other { return true }
        return identifier == other.identifier && list == other.list
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        var identifier = identifier
        if let list = list {
           identifier = list.identifier + "_" + identifier
        }
        
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }

    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return identifier
    }
    
    /// 无板块标识
    static let noneIdentifier = "noneSection"
    
    /// 无板块特征值
    static func none(for list: TodoList?) -> TodoSection {
        let section = TodoSection(identifier: noneIdentifier,
                                  name: resGetString("None Section"),
                                  order: Int64.max)
        section.list = list
        return section
    }
}

struct TodoSectionFeature: Hashable, Equatable, Sortable {
    
    let identifier: String
    
    let name: String?
    
    var order: Int64
    
    let list: TodoListFeature?
    
    /// 显示名称
    var displayName: String {
        return name ?? resGetString("Untitled Section")
    }
    
    var title: String {
        var names = [String]()
        if let list = list {
            names.append(list.displayName)
        } else {
            names.append(resGetString("Inbox"))
        }

        if !isNone {
            names.append(displayName)
        }
        
        return names.joined(separator: "/")
    }
    
    var isNone: Bool {
        return identifier == TodoSection.noneIdentifier
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    // MARK: - Equatable
    static func == (lhs: TodoSectionFeature, rhs: TodoSectionFeature) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.list == rhs.list
    }
    
    /// 无板块特征值
    static func none(for list: TodoListFeature?) -> TodoSectionFeature {
        return TodoSectionFeature(identifier: TodoSection.noneIdentifier,
                                  name: nil,
                                  order: Int64.max,
                                  list: list)
    }
    
    static var defaultSection: TodoSectionFeature {
        return .none(for: nil)
    }
}

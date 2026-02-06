//
//  TodoFilterValue.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/9.
//

import Foundation

protocol PredicateProvider {
    /// 生成过滤任务的谓词
    var predicate: NSPredicate? { get }
}

// MARK: - 列表过滤值
struct TodoListFilterValue: Hashable, Codable, PredicateProvider {
    
    /// 是否包含收件箱
    var includeInbox: Bool?
    
    /// 列表标识数组
    var identifiers: [String]?
    
    var lists: [TodoList]? {
        if let identifiers = identifiers {
            return todo.getLists(with: identifiers)
        }
        
        return nil
    }
    
    /// 列表信息
    var listsInfo: (includeInbox: Bool?, lists: [TodoList]?)? {
        return (includeInbox, lists)
    }
    
    /// 描述
    var description: String? {
        var names = [String]()
        if let includeInbox = includeInbox, includeInbox {
            names.append(TodoSmartList.inbox.title)
        }
        
        if let lists = lists {
            for list in lists {
                let name = list.name ?? resGetString("Untitled")
                names.append(name)
            }
        }
        
        guard names.count > 0 else {
            return nil
        }
        
        return names.joined(separator: ", ")
    }
    
    /// 生成过滤任务的谓词
    var predicate: NSPredicate? {
        var inboxPredicate: NSPredicate?
        // 如果包含收件箱，则创建对应的谓词条件
        if let includeInbox = includeInbox, includeInbox {
            let inboxCondition: PredicateCondition = (TodoTaskKey.list, .isEmpty)
            inboxPredicate = NSPredicate.predicate(with: inboxCondition)
        }
        
        // 如果没有指定列表标识符，则直接返回收件箱谓词
        guard let identifiers = identifiers, identifiers.count > 0 else {
            return inboxPredicate
        }
        
        // 构建列表标识符的完整路径
        let listIdentifier = TodoTaskKey.list + "." + TodoListKey.identifier
        // 创建列表过滤条件
        let listCondition: PredicateCondition = (listIdentifier, .belongsTo(identifiers))
        let listPredicate = NSPredicate.predicate(with: listCondition)
        // 如果存在收件箱谓词，则返回收件箱和列表谓词的组合
        if let inboxPredicate = inboxPredicate {
            return NSCompoundPredicate(orPredicateWithSubpredicates: [inboxPredicate, listPredicate])
        }
        
        return listPredicate
    }
}

// MARK: - 我的一天过滤值
enum TodoMyDayFilterValue: Int, Hashable, Codable, TPMenuRepresentable, PredicateProvider {
    case added = 1
    case notAdded
    
    var title: String {
        switch self {
        case .added:
            return resGetString("Added")
        case .notAdded:
            return resGetString("Not Added")
        }
    }
    
    var description: String? {
        return title
    }
    
    var predicate: NSPredicate? {
        switch self {
        case .added:
            return NSPredicate.predicate(with: (TodoTaskKey.isAddedToMyDay, .isTrue))
        case .notAdded:
            return NSPredicate.predicate(with: (TodoTaskKey.isAddedToMyDay, .isFalse))
        }
    }
}

// MARK: - 优先级过滤值
struct TodoPriorityFilterValue: Hashable, Codable, PredicateProvider {
    
    var priorities: [TodoTaskPriority]?
    
    // MARK: - 描述
    var description: String? {
        guard let priorities = priorities, priorities.count > 0 else {
            return nil
        }
        
        var strings = [String]()
        for priority in TodoTaskPriority.allCases {
            if priorities.contains(priority) {
                strings.append(priority.title)
            }
        }
        
        return strings.joined(separator: ", ")
    }
    
    /// 生成过滤任务的谓词
    var predicate: NSPredicate? {
        guard let priorities = priorities,
                priorities.count > 0,
                Set(priorities) != Set(TodoTaskPriority.allCases) else {
            return nil
        }

        var conditions = [PredicateCondition]()
        for priority in priorities {
            let condition: PredicateCondition = (TodoTaskKey.priority, .equal(priority.rawValue))
            conditions.append(condition)
        }
        
        /// OR 关系
        return conditions.orPredicate()
    }
}

// MARK: - 标签过滤值
struct TodoTagFilterValue: Hashable, Codable, PredicateProvider {
    
    /// 是否包含无标签
    var includeNoTag: Bool?
    
    /// 标签标识数组
    var identifiers: [String]?
    
    /// 标识对应的标签数组
    var tags: [TodoTag]? {
        if let identifiers = identifiers {
            return todo.getTags(with: identifiers)
        }
        
        return nil
    }
    
    /// 标签信息
    var tagsInfo: (includeNoTag: Bool?, tags: [TodoTag]?)? {
        return (includeNoTag, tags)
    }
    
    var description: String? {
        var names = [String]()
        if let includeNoTag = includeNoTag, includeNoTag {
            let name = resGetString("No tag")
            names.append(name)
        }

        if let tags = tags {
            for tag in tags {
                let name = tag.name ?? resGetString("Untitled")
                names.append(name)
            }
        }

        guard names.count > 0 else {
            return nil
        }
        
        return names.joined(separator: ", ")
    }
    
    /// 生成过滤任务标签的谓词
    var predicate: NSPredicate? {
        var noTagPredicate: NSPredicate?
        if let includeNoTag = includeNoTag, includeNoTag {
            noTagPredicate = NSPredicate(format: "\(TodoTaskKey.tags).@count == 0")
        }
        
        guard let identifiers = identifiers, identifiers.count > 0 else {
            return noTagPredicate
        }
        
        // 构建列表标识符的完整路径
        let tagIdentifier = TodoTaskKey.tags + "." + TodoTagKey.identifier
        let tagCondition: PredicateCondition = (tagIdentifier, .anyBelongsTo(identifiers))
        let tagPredicate = NSPredicate.predicate(with: tagCondition)
        
        // 如果存在无标签谓词，则返回无标签和标签谓词的组合
        if let noTagPredicate = noTagPredicate {
            return NSCompoundPredicate(orPredicateWithSubpredicates: [noTagPredicate,
                                                                      tagPredicate])
        }
        
        return tagPredicate
    }
    
}

// MARK: - 进度过滤值
enum TodoProgressFilterType: Int, Hashable, Codable, TPMenuRepresentable {
    case notSetted = 1
    case setted
    
    var title: String {
        switch self {
        case .setted:
            return resGetString("Setted")
        case .notSetted:
            return resGetString("Not Setted")
        }
    }
}

/// 进度过滤指定值
struct TodoProgressFilterSpecificValue: Hashable, Codable {
    
    static var defaultOperator: ComparisonOperator = .greaterThan
    
    static var defaultPercentage = 50
    
    /// 算数操作符
    enum ComparisonOperator: String, Codable, TPMenuRepresentable {
        case greaterThan = ">"
        case greaterOrEqual = ">="
        case lessThan = "<"
        case lessOrEqual = "<="
        case equal = "=="
        
        var title: String {
            var shotName: String
            switch self {
            case .greaterThan:
                shotName = "Greater Than"
            case .greaterOrEqual:
                shotName = "Greater Or Equal"
            case .lessThan:
                shotName = "Less Than"
            case .lessOrEqual:
                shotName = "Less Or Equal"
            case .equal:
                shotName = "Equal"
            }
            
            return resGetString(shotName)
        }
    }

    /// 算数操作符
    var comparisonOperator: ComparisonOperator? = Self.defaultOperator
    
    /// 百分比数值（1～100）
    var percentage: Int? = Self.defaultPercentage
    
    /// 描述
    var description: String? {
        let op = getComparisonOperator()
        let val = getPercentage()
        return op.rawValue + "\(val)%"
    }
    
    var predicateComparison: PredicateComparison {
        let comparison: PredicateComparison
        let op = getComparisonOperator()
        let val = Float(getPercentage()) / 100.0
        switch op {
        case .greaterThan:
            comparison = .greaterThan(val)
        case .greaterOrEqual:
            comparison = .greaterThanOrEqual(val)
        case .lessThan:
            comparison = .lessThan(val)
        case .lessOrEqual:
            comparison = .lessThanOrEqual(val)
        case .equal:
            comparison = .equal(val)
        }
        
        return comparison
    }
    
    func getComparisonOperator() -> ComparisonOperator {
        if let comparisonOperator = comparisonOperator {
            return comparisonOperator
        }
        
        return Self.defaultOperator
    }
    
    func getPercentage() -> Int {
        var value = percentage ?? Self.defaultPercentage
        clampValue(&value, 0, 100)
        return value
    }
}

struct TodoProgressFilterValue: Hashable, Codable, PredicateProvider {
    
    /// 进度过滤类型
    var filterType: TodoProgressFilterType?
    
    /// 进度过滤指定值
    var specificValue: TodoProgressFilterSpecificValue?
    
    /// 描述
    var description: String? {
        guard let filterType = filterType else {
            return nil
        }
        
        guard filterType == .setted else {
            return filterType.title
        }
        
        let valueText: String
        if let description = specificValue?.description {
            valueText = description
        } else {
            valueText = TodoFilterProgressSpecificValueType.any.title
        }
        
        return filterType.title + "(\(valueText))"
    }
    
    var predicate: NSPredicate? {
        guard let filterType = filterType else {
            return nil
        }

        /// 未设置
        if filterType == .notSetted {
            let emptyCondition: PredicateCondition = (TodoTaskKey.progress, .isEmpty)
            return NSPredicate.predicate(with: emptyCondition)
        }
        
        /// 已设置
        let notEmptyCondition: PredicateCondition = (TodoTaskKey.progress, .isNotEmpty)
        guard let specificValue = specificValue else {
            return NSPredicate.predicate(with: notEmptyCondition)
        }

        var conditions = [notEmptyCondition]
        let key = TodoTaskKey.progress + "." + TodoProgressKey.completionRate
        let comparison = specificValue.predicateComparison
        let valueCondition: PredicateCondition = (key, comparison)
        conditions.append(valueCondition)
        return conditions.andPredicate()
    }
}

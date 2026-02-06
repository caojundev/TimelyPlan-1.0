//
//  FilterRule.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/23.
//

import Foundation

public class TodoFilterRule: NSObject, Codable, NSCopying {
    
    /// 日期
    var dateFilterValue: TodoDateFilterValue?
    
    /// 列表
    var listFilterValue: TodoListFilterValue?
    
    /// 标签
    var tagFilterValue: TodoTagFilterValue?
    
    /// 我的一天
    var myDayFilterValue: TodoMyDayFilterValue?
    
    /// 进度
    var progressFilterValue: TodoProgressFilterValue?
    
    /// 优先级
    var priorityFilterValue: TodoPriorityFilterValue?
    
    var isValid: Bool {
        return dateFilterValue != nil ||
               listFilterValue != nil ||
               tagFilterValue != nil ||
               myDayFilterValue != nil ||
               progressFilterValue != nil ||
               priorityFilterValue != nil
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = TodoFilterRule()
        copy.dateFilterValue = dateFilterValue
        copy.listFilterValue = listFilterValue
        copy.tagFilterValue = tagFilterValue
        copy.myDayFilterValue = myDayFilterValue
        copy.progressFilterValue = progressFilterValue
        copy.priorityFilterValue = priorityFilterValue
        return copy
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(dateFilterValue)
        hasher.combine(listFilterValue)
        hasher.combine(tagFilterValue)
        hasher.combine(myDayFilterValue)
        hasher.combine(progressFilterValue)
        hasher.combine(priorityFilterValue)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoFilterRule else { return false }
        if self === other { return true }
        return dateFilterValue == other.dateFilterValue &&
               listFilterValue == other.listFilterValue &&
               tagFilterValue == other.tagFilterValue &&
               myDayFilterValue == other.myDayFilterValue &&
               progressFilterValue == other.progressFilterValue &&
               priorityFilterValue == other.priorityFilterValue
    }
    
    /// 获取过滤类型对应的过滤值
    func filterValue(for filterType: TodoFilterType) -> Any? {
        switch filterType {
        case .list:
            return listFilterValue
        case .date:
            return dateFilterValue
        case .priority:
            return priorityFilterValue
        case .tag:
            return tagFilterValue
        case .myDay:
            return myDayFilterValue
        case .progress:
            return progressFilterValue
        }
    }
}

// MARK: - 描述
extension TodoFilterRule {
    
    var attributedDescription: ASAttributedString? {
        var results = [ASAttributedString]()
        for filterType in TodoFilterType.allCases {
            if let result = attributedDescription(for: filterType) {
                results.append(result)
            }
        }
        
        return results.joined(separator: " • ")
    }
    
    private func attributedDescription(for filterType: TodoFilterType) -> ASAttributedString? {
        var iconName: String
        var description: String?
        switch filterType {
        case .list:
            iconName = "list"
            description = listFilterValue?.description
        case .date:
            iconName = "date"
            description = dateFilterValue?.description
        case .priority:
            iconName = "priority"
            description = priorityFilterValue?.description
        case .tag:
            iconName = "tag"
            description = tagFilterValue?.description
        case .myDay:
            iconName = "myDay"
            description = myDayFilterValue?.description
        case .progress:
            iconName = "progress"
            description = progressFilterValue?.description
        }
        
        guard let description = description else {
            return nil
        }
        
        iconName = "todo_filter_indicator_" + iconName
        let iconSize: CGSize = .size(3)
        guard let icon = resGetImage(iconName, size: iconSize) else {
            return description.attributedString
        }
        
        return .string(image: icon, imageSize: iconSize, trailingText: description)
    }
}

// MARK: - 默认过滤规则
extension TodoFilterRule {
    
    /// 返回象限的默认的过滤规则
    static func defaultFilterRule(for quadrant: Quadrant) -> TodoFilterRule {
        let priority: TodoTaskPriority
        switch quadrant {
        case .urgentImportant:
            priority = .high
        case .notUrgentImportant:
            priority = .medium
        case .urgentNotImportant:
            priority = .low
        case .notUrgentNotImportant:
            priority = .none
        }
        
        let rule = TodoFilterRule()
        rule.priorityFilterValue = TodoPriorityFilterValue(priorities: [priority])
        return rule
    }
    
    static var defaultQuadrantFilterRules: [Quadrant: TodoFilterRule] {
        var rules: [Quadrant: TodoFilterRule] = [:]
        for quadrant in Quadrant.allCases {
            rules[quadrant] = defaultFilterRule(for: quadrant)
        }
        
        return rules
    }
}

// MARK: - 谓词
extension TodoFilterRule {
    
    var predicate: NSPredicate? {
        var predicates: [NSPredicate] = []
        for filterType in TodoFilterType.allCases {
            if let predicate = predicate(for: filterType) {
                predicates.append(predicate)
            }
        }
        
        guard predicates.count > 0 else {
            return nil
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    func predicate(for filterType: TodoFilterType) -> NSPredicate? {
        let filterValue = filterValue(for: filterType) as? PredicateProvider
        return filterValue?.predicate
    }
}

extension TodoFilterRule {
    
    /// 默认所属列表
    var defaultList: TodoList? {
        guard let listsInfo = listFilterValue?.listsInfo else {
            return nil
        }
        
        if let includeInbox = listsInfo.includeInbox, includeInbox {
            return nil
        }
        
        if let lists = listsInfo.lists {
            return lists.first
        }
        
        return nil
    }
    
    /// 默认标签信息
    var defaultTags: Set<TodoTag>? {
        if let tagsInfo = tagFilterValue?.tagsInfo, let tags = tagsInfo.tags, tags.count > 0 {
            return Set(tags)
        }
        
        return nil
    }
 
    /// 优先级
    var defaultPriority: TodoTaskPriority? {
        var priority: TodoTaskPriority?
        if let priorities = priorityFilterValue?.priorities, priorities.count > 0 {
            /// 选择最高优先级作为默认优先级
            priority = priorities.sorted { $0.rawValue < $1.rawValue }.last
        }
        
        return priority
    }
    
    /// 是否添加到我的一天
    var defaultAddedToMyDay: Bool {
        return myDayFilterValue == .added
    }
    
    /// 当前过滤规则对应的编辑进度
    var defaultProgress: TodoEditProgress? {
        guard let filterValue = progressFilterValue, filterValue.filterType == .setted else {
            return nil
        }
        
        var progress = TodoEditProgress()
        progress.adjustCurrentValue(toMatch: filterValue.specificValue)
        return progress
    }
    
    var isProgressSetted: Bool {
        if let filterValue = progressFilterValue, filterValue.filterType == .setted {
            return  true
        }
        
        return false
    }
 
    /// 过滤规则对应的任务计划
    var defaultSchedule: TaskSchedule? {
        guard let startDate = dateFilterValue?.suitableStartDate() else {
            return nil
        }
        
        let dateInfo = TaskDateInfo.allDayDateInfo(startDate: startDate)
        let schedule = TaskSchedule(dateInfo: dateInfo, reminder: nil, repeatRule: nil)
        return schedule
    }
    
    /// 获取过滤日期范围
    var dateRange: DateRange? {
        return dateFilterValue?.dateRange()
    }

}

//
//  TodoSort.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/19.
//

import Foundation

/// 排列类型
enum TodoSortType: String, Codable, TPMenuRepresentable {
    case manually  /// 手动
    case creationDate     /// 创建时间
    case modificationDate /// 修改日期
    case completionDate /// 完成日期
    case startDate /// 开始日期
    case dueDate   /// 截止日期
    
    var iconName: String? {
        return "todo_sort_type_" + self.rawValue + "_24"
    }
    
    var title: String {
        switch self {
        case .creationDate:
            return resGetString("Creation Date")
        case .modificationDate:
            return resGetString("Modification Date")
        case .completionDate:
            return resGetString("Completion Date")
        case .startDate:
            return resGetString("Start Date")
        case .dueDate:
            return resGetString("Due Date")
        default:
            return resGetString(rawValue.capitalizedFirstLetter())
        }
    }
    
    static func completionDateExcluded() -> [TodoSortType] {
        var types = TodoSortType.allCases
        types.remove(.completionDate)
        return types
    }
    
}

/// 排列顺序
enum TodoSortOrder: Int, Codable, TPMenuRepresentable {
    case ascending = 0 /// 升序
    case descending    /// 降序
    
    var iconName: String? {
        switch self {
        case .ascending:
            return "todo_sort_order_ascending_24"
        case .descending:
            return "todo_sort_order_descending_24"
        }
    }
    
    static func titles() -> [String] {
        return ["Ascending", "Descending"]
    }
}

struct TodoSort: Codable, Equatable {
    
    /// 排列类型
    var type: TodoSortType = .manually
    
    /// 排列顺序
    var order: TodoSortOrder = .ascending
    
    var sortDescriptor: SortDescriptor<TodoTask> {
        let order: SortOrder = self.order == .ascending ? .forward : .reverse
        let descriptor: SortDescriptor<TodoTask>
        switch type {
        case .manually:
            descriptor = SortDescriptor(\TodoTask.order, order: .forward)
        case .creationDate:
            descriptor = SortDescriptor(\TodoTask.creationDate, order: order)
        case .modificationDate:
            descriptor = SortDescriptor(\TodoTask.modificationDate, order: order)
        case .completionDate:
            descriptor = SortDescriptor(\TodoTask.completionDate, order: order)
        case .startDate:
            descriptor = SortDescriptor(\TodoTask.startDate, order: order)
        case .dueDate:
            descriptor = SortDescriptor(\TodoTask.dueDate, order: order)
        }
        
        return descriptor
    }
}

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
    case startDate /// 开始日期
    case dueDate   /// 截止日期
    
    var iconName: String? {
        return "SortType" + defaultIconName()
    }
    
    var title: String {
        switch self {
        case .creationDate:
            return resGetString("Creation Date")
        case .modificationDate:
            return resGetString("Modification Date")
        case .startDate:
            return resGetString("Start Date")
        case .dueDate:
            return resGetString("Due Date")
        default:
            return resGetString(rawValue.capitalizedFirstLetter())
        }
    }
}

/// 排列顺序
enum TodoSortOrder: Int, Codable, TPMenuRepresentable {
    case ascending = 0 /// 升序
    case descending    /// 降序
    
    var iconName: String? {
        switch self {
        case .ascending:
            return "SortOrderAscending"
        case .descending:
            return "SortOrderDescending"
        }
    }
    
    static func titles() -> [String] {
        return ["Ascending", "Descending"]
    }
}

struct TodoSort: Equatable {
    
    /// 排列类型
    var type: TodoSortType = .manually
    
    /// 排列顺序
    var order: TodoSortOrder = .ascending
    
    var sortTerm: SortTerm {
        let key: String = Self.key(for: type)
        let ascending = order == .ascending
        return (key, ascending)
    }
    
    static func key(for type: TodoSortType) -> String {
        let key: String
        switch type {
        case .manually:
            key = TodoTaskKey.order
        case .creationDate:
            key = TodoTaskKey.creationDate
        case .modificationDate:
            key = TodoTaskKey.modificationDate
        case .startDate:
            key = TodoTaskKey.startDate
        case .dueDate:
            key = TodoTaskKey.dueDate
        }
        
        return key
    }
}

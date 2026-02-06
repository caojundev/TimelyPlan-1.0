//
//  TodoListRepresentable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/23.
//

import Foundation

enum TodoListMode: String, TPMenuRepresentable {
    case user      /// 用户列表
    case inbox     /// 收件箱
    case completed /// 已完成
    case planned   /// 计划内
    case trash     /// 已删除
}

protocol TodoListRepresentable: NSObjectProtocol {
    
    /// 列表类型
    var listMode: TodoListMode { get }
    
    /// 列表标识
    var identifier: String? {get set}
    
    /// 列表显示标题
    func displayTitle() -> String
    
    /// 列表中是否有任务
    func hasTask() -> Bool
}

extension TodoListRepresentable {
    
    /// 获取排序条目数组
    func sortTerms(for sort: TodoSort) -> [SortTerm] {
        var sortTerms = [sort.sortTerm]
        let auxiliaryTypes: [TodoSortType] = [.manually, .startDate, .dueDate]
        guard auxiliaryTypes.contains(sort.type) else {
            /// 不需要辅助排序，直接返回排序条目
            return sortTerms
        }
        
        /// 以创建日期辅助排序
        let ascending = sort.order == .ascending
        sortTerms.append((TodoTaskKey.creationDate, ascending))
        return sortTerms
    }
    
    /// 允许的分组类型
    func allowGroupTypes() -> [TodoGroupType] {
        switch listMode {
        case .user, .inbox:
            return [.default, .startDate, .dueDate, .priority, .none]
        case .completed:
            return [.list]
        case .planned:
            return [.dueDate]
        case .trash:
            return [.none]
        }
    }
    
    /// 允许的排序类型
    func allowSortTypes() -> [TodoSortType] {
        switch listMode {
        case .user, .inbox:
            return TodoSortType.allCases
        case .completed:
            return [.manually]
        case .planned:
            return [.dueDate]
        case .trash:
            return [.creationDate]
        }
    }
    
    /// 列表特定排序类型允许的排列顺序
    func allowSortOrders(for sortType: TodoSortType) -> [TodoSortOrder] {
        switch listMode {
        case .user, .inbox:
            if sortType == .manually {
                return [.ascending] /// 手动排序仅支持升序
            }
            
            return TodoSortOrder.allCases
        case .completed:
            return [.ascending]
        case .planned:
            return TodoSortOrder.allCases
        case .trash:
            return [.descending]
        }
    }
    
    // MARK: - 验证
    func validatedGroupType(_ groupType: TodoGroupType?) -> TodoGroupType {
        let allowTypes = allowGroupTypes()
        guard let groupType = groupType, allowTypes.contains(groupType) else {
            return allowTypes.first!
        }

        return groupType
    }
    
    func validatedSortType(_ sortType: TodoSortType?) -> TodoSortType {
        let allowTypes = allowSortTypes()
        guard let sortType = sortType, allowTypes.contains(sortType) else {
            return allowTypes.first!
        }

        return sortType
    }
    
    func validatedSortOrder(_ sortOrder: TodoSortOrder?,
                            for sortType: TodoSortType) -> TodoSortOrder {
        let allowOrders = allowSortOrders(for: sortType)
        guard let sortOrder = sortOrder, allowOrders.contains(sortOrder) else {
            return allowOrders.first!
        }

        return sortOrder
    }
    
    /// 返回一个验证合法的排序对象
    func validatedSort(_ sort: TodoSort) -> TodoSort {
        let sortType = validatedSortType(sort.type)
        let sortOrder = validatedSortOrder(sort.order, for: sortType)
        return TodoSort(type: sortType, order: sortOrder)
    }
    
}

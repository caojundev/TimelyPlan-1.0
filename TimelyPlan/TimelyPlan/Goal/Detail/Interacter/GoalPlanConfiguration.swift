//
//  GoalPlanConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation
import UIKit

class GoalPlanConfiguration: Equatable, IdentifiableItem {
    
    var identifier: String
    
    private(set) var goalPlan: GoalPlan
    
    init(goalPlan: GoalPlan) {
        self.identifier = goalPlan.identifier
        self.goalPlan = goalPlan
    }
    
    // MARK: - Equatable
    static func == (lhs: GoalPlanConfiguration, rhs: GoalPlanConfiguration) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    /// 是否可以添加任务
    func canAddTask() -> Bool {
        return false
    }
    
    /// 添加按钮背景颜色
    func addButtonBackColor() -> UIColor {
        return .primary
    }
    
    /// 允许的列表选项
    func allowOptions() -> [GoalPlanOption]? {
        return GoalPlanOption.allCases
    }
    
    /// 允许的分组类型
    func allowGroupTypes() -> [TodoGroupType] {
        return [.default, .none]
    }
    
    /// 首选排列顺序
    var preferredSortOrder: TodoSortOrder {
        return .ascending
    }
    
    /// 允许的排序类型
    func allowSortTypes() -> [TodoSortType] {
        return TodoSortType.completionDateExcluded()
    }
    
    /// 根据排序类型返回允许的排列顺序
    func allowSortOrders(for sortType: TodoSortType) -> [TodoSortOrder] {
        return TodoSortOrder.allCases
    }
    
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

    func validatedSortOrder(_ sortOrder: TodoSortOrder?, for sortType: TodoSortType) -> TodoSortOrder {
        let allowOrders = allowSortOrders(for: sortType)
        guard let sortOrder = sortOrder, allowOrders.contains(sortOrder) else {
            if allowOrders.contains(preferredSortOrder) {
                /// 返回首选排列顺序
                return preferredSortOrder
            }
            
            return allowOrders.first ?? .ascending
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

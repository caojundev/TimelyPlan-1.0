//
//  GoalPlanConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation
import UIKit

/// 目标列表配置基类（目标计划 / 收件箱等共用）
class GoalListConfiguration: Equatable, IdentifiableItem {
    
    var identifier: String
    
    /// 列表特征信息（名称、颜色）
    private(set) var feature: GoalPlanFeature
    
    init(feature: GoalPlanFeature) {
        self.identifier = feature.identifier
        self.feature = feature
    }
    
    // MARK: - Equatable
    static func == (lhs: GoalListConfiguration, rhs: GoalListConfiguration) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    // MARK: - Public Methods
    /// 列表标题图标名称
    var iconName: String? {
        return "goal_24"
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
    func allowGroupTypes() -> [GoalTaskGroupType] {
        return [.default, .targetStatus, .weight, .none]
    }
    
    /// 首选排列顺序
    var preferredSortOrder: TodoSortOrder {
        return .ascending
    }
    
    /// 允许的排序类型
    func allowSortTypes() -> [TodoSortType] {
        return [.manually, .creationDate, .modificationDate, .startDate, .dueDate]
    }
    
    /// 根据排序类型返回允许的排列顺序
    func allowSortOrders(for sortType: TodoSortType) -> [TodoSortOrder] {
        if sortType == .manually {
            return [.ascending] /// 手动排序仅支持升序
        }
        
        return TodoSortOrder.allCases
    }
    
    func validatedGroupType(_ groupType: GoalTaskGroupType?) -> GoalTaskGroupType {
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
    
    /// 获取目标任务（子类重写）
    func fetchTasks(completion: @escaping ([GoalTask]?) -> Void) {
        completion(nil)
    }
    
    /// 更新特征信息
    func updateFeature(_ feature: GoalPlanFeature) {
        self.identifier = feature.identifier
        self.feature = feature
    }
}

/// 目标计划配置
class GoalPlanConfiguration: GoalListConfiguration {
    
    private(set) var goalPlan: GoalPlan
    
    init(goalPlan: GoalPlan) {
        self.goalPlan = goalPlan
        super.init(feature: goalPlan.feature)
    }
    
    // MARK: - Public Methods
    func updateGoalPlan(_ goalPlan: GoalPlan) {
        guard identifier == goalPlan.identifier else {
            return
        }
        
        self.goalPlan = goalPlan
        self.updateFeature(goalPlan.feature)
    }
    
    override func fetchTasks(completion: @escaping ([GoalTask]?) -> Void) {
        GoalRepository.fetchGoalTasks(of: goalPlan, completion: completion)
    }
}

/// 收件箱配置（未归属任何目标计划的目标任务）
class GoalInboxConfiguration: GoalListConfiguration {
    
    init() {
        super.init(feature: .inboxFeature)
    }
    
    override var iconName: String? {
        return "todo_list_inbox_24"
    }
    
    override func canAddTask() -> Bool {
        return true
    }
    
    /// 收件箱仅支持分组与排序
    override func allowOptions() -> [GoalPlanOption]? {
        return [.group, .sort]
    }
    
    /// 不支持手动排序，默认按创建时间排序
    override func allowSortTypes() -> [TodoSortType] {
        return [.creationDate, .modificationDate, .startDate, .dueDate]
    }
    
    override func fetchTasks(completion: @escaping ([GoalTask]?) -> Void) {
        GoalRepository.fetchInboxGoalTasks(completion: completion)
    }
}

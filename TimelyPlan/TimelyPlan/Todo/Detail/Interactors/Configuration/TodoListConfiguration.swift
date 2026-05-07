//
//  TodoListConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/20.
//

import Foundation
import UIKit

class TodoListConfiguration: Equatable, IdentifiableItem {
    
    var identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: - Equatable
    static func == (lhs: TodoListConfiguration, rhs: TodoListConfiguration) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    /// 创建内容视图控制器
    func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return UIViewController()
    }
    
    /// 详情选项
    func detailOption() -> TodoTaskDetailOption {
        return .allExceptList
    }
    
    func quickAddTask() -> TodoQuickAddTask? {
        return nil
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
    func allowListOptions() -> [TodoListOption]? {
        return TodoListOption.allCases
    }
    
    /// 允许的分组类型
    func allowGroupTypes() -> [TodoGroupType] {
        return TodoGroupType.allCases
    }
    
    /// 首选排列顺序
    var preferredSortOrder: TodoSortOrder {
        return .ascending
    }
    
    /// 允许的排序类型
    func allowSortTypes() -> [TodoSortType] {
        return TodoSortType.allCases
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

extension TodoListConfiguration {
    
    static func configuration(for object: Any) -> TodoListConfiguration! {
        switch object {
        case let list as TodoList:
            return TodoUserListConfiguration(list: list)
        case let tag as TodoTag:
            return TodoTagListConfiguration(tag: tag)
        case let filter as TodoFilter:
            return TodoFilterListConfiguration(filter: filter)
        case let smartList as TodoSmartList:
            return TodoSmartListConfiguration.smartListConfiguration(for: smartList)
        default:
            return nil
        }
    }
}

class TodoUserListConfiguration: TodoListConfiguration {
    
    private(set) var list: TodoList
    
    init(list: TodoList) {
        self.list = list
        super.init(identifier: list.identifier)
    }
    
    /// 更新列表
    func updateList(_ list: TodoList) {
        guard self.identifier == list.identifier else {
            return
        }
        
        self.list = list
    }
    
    override func quickAddTask() -> TodoQuickAddTask? {
        let task = TodoQuickAddTask()
        task.list = self.list
        return task
    }
    
    override func canAddTask() -> Bool {
        return true
    }
    
    override func allowListOptions() -> [TodoListOption]? {
        return [.select, .showCompleted, .showDetail, .layout, .group, .sort, .edit]
    }
    
    override func allowGroupTypes() -> [TodoGroupType] {
        return [.default, .startDate, .dueDate, .priority, .none]
    }
    
    override func allowSortTypes() -> [TodoSortType] {
        return TodoSortType.allCases
    }
    
    override func allowSortOrders(for sortType: TodoSortType) -> [TodoSortOrder] {
        if sortType == .manually {
            return [.ascending] /// 手动排序仅支持升序
        }
        
        return TodoSortOrder.allCases
    }
    
    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        let layoutType = interactor.layoutType()
        if layoutType == .list {
            return TodoUserTaskListViewController(interactor: interactor)
        } else {
            return TodoTaskBoardViewController(interactor: interactor)
        }
    }
}


class TodoTagListConfiguration: TodoListConfiguration {
    
    private(set) var tag: TodoTag
    
    init(tag: TodoTag) {
        self.tag = tag
        super.init(identifier: tag.identifier)
    }
    
    /// 更新标签
    func updateTag(_ tag: TodoTag) {
        guard self.identifier == tag.identifier else {
            return
        }
        
        self.tag = tag
    }
    
    override func quickAddTask() -> TodoQuickAddTask? {
        let task = TodoQuickAddTask()
        task.tags = [tag]
        return task
    }
    
    override func detailOption() -> TodoTaskDetailOption {
        return .allExceptCompletionDate
    }
    
    override func allowListOptions() -> [TodoListOption]? {
        return [.select, .showCompleted, .showDetail, .layout, .group, .sort, .edit]
    }
    
    override func canAddTask() -> Bool {
        return true
    }
    
    override func addButtonBackColor() -> UIColor {
        return .orange(5)
    }

    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return TodoTagTaskListViewController(interactor: interactor)
    }
}


class TodoFilterListConfiguration: TodoListConfiguration {
    
    private(set) var filter: TodoFilter
    
    init(filter: TodoFilter) {
        self.filter = filter
        super.init(identifier: filter.identifier)
    }

    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return TodoFilterTaskListViewController(interactor: interactor)
    }
    
    override func quickAddTask() -> TodoQuickAddTask? {
        return filter.matchingQuickAddTask ?? TodoQuickAddTask()
    }
    
    override func detailOption() -> TodoTaskDetailOption {
        return .allExceptCompletionDate
    }
    
    override func allowListOptions() -> [TodoListOption]? {
        return [.select, .showCompleted, .showDetail, .layout, .group, .sort, .edit]
    }
    
    override func canAddTask() -> Bool {
        return true
    }
    
    /// 更新过滤器
    func updateFilter(_ filter: TodoFilter) {
        guard self.identifier == filter.identifier else {
            return
        }
        
        self.filter = filter
    }
    
}

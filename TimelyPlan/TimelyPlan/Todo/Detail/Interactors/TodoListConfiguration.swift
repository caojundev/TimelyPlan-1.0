//
//  TodoListConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/20.
//

import Foundation
import UIKit

class TodoListConfiguration {
    
    static func configuration(for object: Any) -> TodoListConfiguration! {
        switch object {
        case let list as TodoList:
            return TodoUserListConfiguration(list: list)
        case let smartList as TodoSmartList:
            return TodoSmartListConfiguration(list: smartList)
        case let tag as TodoTag:
            return TodoTagListConfiguration(tag: tag)
        default:
            return nil
        }
    }
    
    /// 创建内容视图控制器
    func makeContent() -> UIViewController {
        return UIViewController()
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


class TodoUserListConfiguration: TodoListConfiguration {
    
    let list: TodoList
    
    init(list: TodoList) {
        self.list = list
        super.init()
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
        return [.select, .showCompleted, .layout, .group, .sort, .edit]
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
    
    override func makeContent() -> UIViewController {
        let interactor = TodoListInteractor.interactor(for: self)
        return TodoTaskListViewController(interactor: interactor)
    }
}

class TodoSmartListConfiguration: TodoListConfiguration {
    
    let list: TodoSmartList
    
    init(list: TodoSmartList) {
        self.list = list
        super.init()
    }
    
    override func quickAddTask() -> TodoQuickAddTask? {
        let task = TodoQuickAddTask()
        return task
    }
    
    override func allowListOptions() -> [TodoListOption]? {
        switch list.listType {
        case .inbox:
            return [.select, .showCompleted, .layout, .group, .sort]
        case .completed:
            return [.select, .group, .sort]
        case .planned:
            return [.select, .showCompleted, .layout, .group, .sort]
        case .trash:
            return [.select, .emptyTrash]
        }
    }
    
    override func canAddTask() -> Bool {
        if list.listType == .trash || list.listType == .completed {
            return false
        }
        
        return true
    }
    
    override func addButtonBackColor() -> UIColor {
        return .greenPrimary
    }
    
    override func allowGroupTypes() -> [TodoGroupType] {
        switch list.listType {
        case .inbox:
            return [.default, .startDate, .dueDate, .priority, .none]
        case .completed:
            return [.list]
        case .planned:
            return [.dueDate]
        case .trash:
            return [.none]
        }
    }
    
    override func allowSortTypes() -> [TodoSortType] {
        switch list.listType {
        case .inbox:
            return TodoSortType.allCases
        case .completed:
            return [.manually]
        case .planned:
            return [.dueDate]
        case .trash:
            return [.creationDate]
        }
    }
    
    override func allowSortOrders(for sortType: TodoSortType) -> [TodoSortOrder] {
        switch list.listType {
        case .inbox:
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
    
    override func makeContent() -> UIViewController {
        let interactor = TodoListInteractor.interactor(for: self)
        if list.listType == .trash {
            return TodoTrashTaskListViewController(interactor: interactor)
        }
        
        return TodoTaskListViewController(interactor: interactor)
    }
}

class TodoTagListConfiguration: TodoListConfiguration {
    
    let tag: TodoTag
    
    init(tag: TodoTag) {
        self.tag = tag
        super.init()
    }
    
    override func quickAddTask() -> TodoQuickAddTask? {
        let task = TodoQuickAddTask()
        task.tags = [tag]
        return task
    }
    
    override func allowListOptions() -> [TodoListOption]? {
        return [.select, .showCompleted, .layout, .group, .sort, .edit]
    }
    
    override func canAddTask() -> Bool {
        return true
    }
    
    override func addButtonBackColor() -> UIColor {
        return .orangePrimary
    }

    override func makeContent() -> UIViewController {
        let interactor = TodoListInteractor.interactor(for: self)
        return TodoTaskListViewController(interactor: interactor)
    }
}

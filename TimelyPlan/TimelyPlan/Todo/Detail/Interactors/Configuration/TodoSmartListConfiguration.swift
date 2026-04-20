//
//  TodoSmartListConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/15.
//

import Foundation

class TodoSmartListConfiguration: TodoListConfiguration {
    
    static func smartListConfiguration(for smartList: TodoSmartList) -> TodoSmartListConfiguration {
        switch smartList.listType {
        case .inbox:
            return TodoInboxListConfiguration(list: smartList)
        case .completed:
            return TodoCompletedListConfiguration(list: smartList)
        case .trash:
            return TodoTrashListConfiguration(list: smartList)
        default:
            return TodoSmartListConfiguration(list: smartList)
        }
    }
    
    let list: TodoSmartList
    
    init(list: TodoSmartList) {
        self.list = list
        super.init(identifier: list.identifier)
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
        case .today, .planned, .overdue:
            return [.select, .showCompleted, .layout, .group, .sort]
        case .trash:
            return [.select, .emptyTrash]
        }
    }
    
    override func canAddTask() -> Bool {
        switch list.listType {
        case .overdue, .completed, .trash:
            return false
        default:
            return true
        }
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
        case .today, .planned, .overdue:
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
        case .today, .planned, .overdue:
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
        case .today, .planned, .overdue:
            return TodoSortOrder.allCases
        case .trash:
            return [.descending]
        }
    }
    
    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return TodoSmartTaskListViewController(interactor: interactor)
    }
}

class TodoInboxListConfiguration: TodoSmartListConfiguration {
    
    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return TodoInboxTaskListViewController(interactor: interactor)
    }
}

class TodoCompletedListConfiguration: TodoSmartListConfiguration {
    
    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return TodoCompletedTaskListViewController(interactor: interactor)
    }
}

class TodoTrashListConfiguration: TodoSmartListConfiguration {
    
    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return TodoTrashTaskListViewController(interactor: interactor)
    }
}

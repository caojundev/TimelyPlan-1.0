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
        switch list.listType {
        case .myDay:
            task.isAddedToMyDay = true
        default:
            task.schedule = defaultSchedule(for: list.listType)
        }
        
        return task
    }
    
    private func defaultSchedule(for listType: TodoSmartListType) -> TaskSchedule? {
        var dateInfo: TaskDateInfo?
        switch listType {
        case .today:
            dateInfo = TaskDateInfo()
        case .tomorrow:
            let date = Date().dateByAddingDays(1)!
            dateInfo = TaskDateInfo(date: date)
        case .upcoming:
            let date = Date().dateByAddingDays(2)!
            dateInfo = TaskDateInfo(date: date)
        default:
            break
        }
        
        guard let dateInfo = dateInfo else {
            return nil
        }

        let schedule = TaskSchedule(dateInfo: dateInfo,
                                    reminder: nil,
                                    repeatRule: nil)
        return schedule
    }
    
    override func detailOption() -> TodoTaskDetailOption {
        return .all
    }
    
    override func allowListOptions() -> [TodoListOption]? {
        switch list.listType {
        case .myDay:
            return [.select, .showCompleted, .showDetail, .group, .sort, .search]
        case .inbox:
            return [.select, .showCompleted, .showDetail, .layout, .group, .sort, .search, .manageSection, .importTask]
        case .completed:
            return [.select, .group, .sort, .search]
        case .overdue, .today, .tomorrow, .upcoming:
            return [.select, .showCompleted, .showDetail, .group, .sort, .search]
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
    
    override func allowGroupTypes() -> [TodoGroupType] {
        switch list.listType {
        case .myDay:
            return [.default, .startDate, .dueDate, .priority]
        case .inbox:
            return [.default, .startDate, .dueDate, .priority, .custom, .none]
        case .completed:
            return [.completionDate]
        case .overdue, .today, .tomorrow, .upcoming:
            return [.dueDate]
        case .trash:
            return [.none]
        }
    }
    
    override func allowSortTypes() -> [TodoSortType] {
        switch list.listType {
        case .myDay:
            return [.creationDate, .startDate, .dueDate]
        case .inbox:
            return TodoSortType.completionDateExcluded()
        case .completed:
            return [.completionDate]
        case .overdue, .today, .tomorrow, .upcoming:
            return [.dueDate]
        case .trash:
            return [.creationDate]
        }
    }
    
    override func allowSortOrders(for sortType: TodoSortType) -> [TodoSortOrder] {
        switch list.listType {
        case .myDay:
            return TodoSortOrder.allCases
        case .inbox:
            if sortType == .manually {
                return [.ascending] /// 手动排序仅支持升序
            }
            
            return TodoSortOrder.allCases
        case .completed, .overdue, .today, .tomorrow, .upcoming:
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
    
    override func detailOption() -> TodoTaskDetailOption {
        return .allExceptList
    }
    
    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        let layoutType = interactor.layoutType()
        if layoutType == .list {
            return TodoInboxTaskListViewController(interactor: interactor)
        } else {
            return TodoTaskBoardViewController(interactor: interactor)
        }
    }
}

class TodoCompletedListConfiguration: TodoSmartListConfiguration {
    
    override var preferredSortOrder: TodoSortOrder {
        return .descending
    }
    
    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return TodoCompletedTaskListViewController(interactor: interactor)
    }
}

class TodoTrashListConfiguration: TodoSmartListConfiguration {

    override func makeContent(with interactor: TodoListInteractor) -> UIViewController {
        return TodoTrashTaskListViewController(interactor: interactor)
    }
}

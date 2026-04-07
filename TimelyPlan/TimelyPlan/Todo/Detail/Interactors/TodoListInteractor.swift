//
//  TodoListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoListInteractor {
    
    static func interactor(for configuration: TodoListConfiguration) -> TodoListInteractor {
        switch configuration {
        case let userListConfig as TodoUserListConfiguration:
            return TodoUserListInteractor(configuration: userListConfig)
        case let smartListConfig as TodoSmartListConfiguration:
            return TodoSmartListInteractor(configuration: smartListConfig)
        case let tagListConfig as TodoTagListConfiguration:
            return TodoTagListInteractor(configuration: tagListConfig)
        default:
            return TodoListInteractor(configuration: TodoListConfiguration())
        }
    }

    /// 列表配置
    let configuration: TodoListConfiguration
    
    init(configuration: TodoListConfiguration) {
        self.configuration = configuration
    }
    
    /// 标题
    func title() -> TextRepresentable? {
        return nil
    }
    
    /// 列表选项菜单管理器
    func listOptions() -> [TodoListOption]? {
        guard let options = configuration.allowListOptions() else {
            return nil
        }
        
        return options
    }
    
    
    /// 当前选中任务可用的任务操作类型数组
    func taskActionTypes(for selectedTasks: Set<TodoTask>) -> [TodoTaskActionType] {
        var actionTypes = [TodoTaskActionType]()
        var isAllDone = selectedTasks.count > 0 ? true : false
        for task in selectedTasks {
            if !task.isCompleted {
                isAllDone = false
            }
        }
        
        if isAllDone {
            actionTypes.append(.undone)
        } else {
            actionTypes.append(.done)
        }
        
        actionTypes.append(contentsOf: [.move, .date, .priority, .trash])
        return actionTypes
    }
}

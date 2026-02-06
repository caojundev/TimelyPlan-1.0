//
//  TodoTaskProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/29.
//

import Foundation

/// 待办任务处理通知协议
protocol TodoTaskProcessorDelegate: AnyObject {

    /// 更新进行中的重复任务
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask])
    
    /// 创建重复的待办任务
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask])

    /// 任务被添加到特定分组
    func didCreateTodoTask(_ task: TodoTask, in list: TodoList?)

    /// 待办任务更新
    func didUpdateTodoTask(with infos: [TodoTaskChangeInfo])
    
    /// 任务移动
    func didMoveTodoTasks(with infos: [TodoTaskChangeInfo])
    
    /// 恢复任务
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask])
    
    /// 移动任务到废纸篓
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask])
    
    /// 任务彻底删除
    func didDeleteTodoTasks(_ tasks: [TodoTask])
    
    /// 任务在列表中的顺序发生改变
    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int)
}

class TodoTaskProcessorUpdater: NSObject, TodoTaskProcessorDelegate {
    
    /// 更新进行中的重复任务
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didUpdateActiveRepeatTodoTasks(tasks)
        }
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didCreateRepeatTodoTasks(repeatTasks)
        }
    }
    
    func didUpdateTodoTask(with infos: [TodoTaskChangeInfo]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didUpdateTodoTask(with: infos)
        }
    }
    
    func didCreateTodoTask(_ task: TodoTask, in list: TodoList?) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didCreateTodoTask(task, in: list)
        }
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didDeleteTodoTasks(tasks)
        }
    }
    
    func didMoveTodoTasks(with infos: [TodoTaskChangeInfo]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didMoveTodoTasks(with: infos)
        }
    }
    
    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didReorderTodoTask(task, fromIndex: fromIndex, toIndex: toIndex)
        }
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didRestoreTrashTodoTasks(tasks)
        }
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        notifyDelegates { (delegate: TodoTaskProcessorDelegate) in
            delegate.didMoveTodoTasksToTrash(tasks)
        }
    }
}
